ad_library {
    API for Simulation actions.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::action {}

ad_proc -public simulation::action::edit {
    {-operation "update"}
    {-action_id {}}
    {-workflow_id {}}
    {-array {}}
    {-internal:boolean}
    {-no_complain:boolean}
} {
    Edit an action. 

    @param operation    insert, update, delete

    @param action_id    For update/delete: The action to update or delete. 
                        For insert: Optionally specify a pre-generated action_id for the action.

    @param workflow_id  For update/delete: Optionally specify the workflow_id. If not specified, we will execute a query to find it.
                        For insert: The workflow_id of the new action.
    
    @param array        For insert/update: Name of an array in the caller's namespace with attributes to insert/update.

    @param internal     Set this flag if you're calling this proc from within the corresponding proc 
                        for a particular workflow model. Will cause this proc to not flush the cache 
                        or call workflow::definition_changed_handler, which the caller must then do.

    @param no_complain  Silently ignore extra attributes that we don't know how to handle. 

    @return action_id
    
    @see workflow::action::fsm::edit
} {
    switch $operation {
        update - delete {
            if { [empty_string_p $action_id] } {
                error "You must specify the action_id of the action to $operation."
            }
        }
        insert {}
        default {
            error "Illegal operation '$operation'"
        }
    }
    switch $operation {
        insert - update {
            upvar 1 $array org_row
            if { ![array exists org_row] } {
                error "Array $array does not exist or is not an array"
            }
            array set row [array get org_row]
        }
    }
    switch $operation {
        insert {
            if { [empty_string_p $workflow_id] } {
                error "You must supply workflow_id"
            }
        }
        update - delete {
            if { [empty_string_p $workflow_id] } {
                set workflow_id [workflow::action::get_element \
                                     -action_id $action_id \
                                     -element workflow_id]
            }
        }
    }

    # Parse column values
    switch $operation {
        insert - update {
            set update_clauses [list]
            set insert_names [list]
            set insert_values [list]

            # Handle columns in the sim_tasks table
            foreach attr { 
                attachment_num 
            } {
                if { [info exists row($attr)] } {
                    set varname attr_$attr
                    # Convert the Tcl value to something we can use in the query
                    switch $attr {
                        default {
                            set $varname $row($attr)
                        }
                    }
                    # Add the column to the insert/update statement
                    switch $attr {
                        default {
                            lappend update_clauses "$attr = :$varname"
                            lappend insert_names $attr
                            lappend insert_values :$varname
                        }
                    }
                    unset row($attr)
                }
            }

            # Special-case: array entry recipient_roles (short_name) and recipients (role_id)
            if { [info exists row(recipient_roles)] } {
                if { [info exists row(recipients)] } {
                    error "You cannot supply both recipient_roles (takes short_name) and recipient (takes role_id)"
                }
                set row(recipients) [list]
                foreach recipient_short_name $row(recipient_roles) {
                    lappend row(recipients) [workflow::role::get_id \
                                                 -workflow_id $workflow_id \
                                                 -short_name $recipient_short_name]
                }
                unset row(recipient_roles)
            }
            
            # Handle auxillary rows
            array set aux [list]
            foreach attr { 
                recipients
            } {
                if { [info exists row($attr)] } {
                    set aux($attr) $row($attr)
                    unset row($attr)
                }
            }
        }
    }
    
    db_transaction {
        # Base row
        set action_id [workflow::action::fsm::edit \
                           -internal \
                           -operation $operation \
                           -action_id $action_id \
                           -workflow_id $workflow_id \
                           -array row]

        # sim_tasks row
        switch $operation {
            insert {
                lappend insert_names task_id
                lappend insert_values :action_id

                db_dml insert_action "
                    insert into sim_tasks
                    ([join $insert_names ", "])
                    values
                    ([join $insert_values ", "])
                "
            }
            update {
                if { [llength $update_clauses] > 0 } {
                    db_dml update_action "
                        update sim_tasks
                        set    [join $update_clauses ", "]
                        where  task_id = :action_id
                    "
                }
            }
            delete {
                # Handled through cascading delete
            }
        }

        # Auxilliary rows
        switch $operation {
            insert - update {
                if { [info exists aux(recipients)] } {
                    db_dml delete_old_recipients {
                        delete from sim_task_recipients
                        where task_id = :action_id
                    }
                    foreach recipient_id $aux(recipients) {
                        db_dml insert_recipient {
                            insert into sim_task_recipients
                              (task_id, recipient)
                            values
                              (:action_id, :recipient_id)
                        }
                    }
                    unset aux(recipients)
                }
            }
        }

        if { !$internal_p } {
            workflow::definition_changed_handler -workflow_id $workflow_id
        }
    }

    if { !$internal_p } {
        workflow::flush_cache -workflow_id $workflow_id
    }

    return $action_id
}


ad_proc -public simulation::action::get {
    {-local_only:boolean}
    {-action_id:required}
    {-array:required}
} {
    Get information about a simulation action.

    @param local_only   Set this to only get the attributes from the simulation extension table, 
                        not the ones derived from workflow::action::fsm.
} {
    upvar 1 $array row

    if { !$local_only_p } {
        workflow::action::fsm::get -action_id $action_id -array row
    }
    
    db_1row select_action {
        select attachment_num
        from   sim_tasks
        where  task_id = :action_id
    } -column_array local_row

    set local_row(recipients) {}
    set local_row(recipient_roles) {}
    db_foreach recipient_roles {
        select wr.role_id,
               wr.short_name
        from sim_task_recipients str,
             workflow_roles wr
        where str.task_id = :action_id
          and str.recipient = wr.role_id
    } {
        lappend local_row(recipients) $role_id
        lappend local_row(recipient_roles) $short_name
    }

    array set row [array get local_row]
}


ad_proc -private simulation::action::generate_spec {
    {-action_id {}}
    {-one_id {}}
} {
    Generate the spec for an individual simulation task definition.

    @param action_id The id of the action to generate spec for.

    @param one_id    Same as action_id, just used for consistency across roles/actions/states.

    @return spec     The actions spec

    @author Lars Pind (lars@collaboraid.biz)
} {
    if { [empty_string_p $action_id] } {
        if { [empty_string_p $one_id] } {
            error "You must supply either action_id or one_id"
        }
        set action_id $one_id
    } else {
        if { ![empty_string_p $one_id] } {
            error "You can only supply either action_id or one_id"
        }
    }

    # Get parent spec
    array set row [workflow::action::fsm::generate_spec -action_id $action_id]

    # Get local spec, remove unwanted entries
    get -action_id $action_id -array local_row -local_only
    array unset local_row recipients
    
    # Copy local stuff in over the parent stuff
    array set row [array get local_row]

    # Output the entire thing in alpha sort order
    foreach name [lsort [array names row]] {
        if { ![empty_string_p $row($name)] } {
            lappend spec $name $row($name)
        }
    }

    return $spec
}

ad_proc -public simulation::action::get_ids {
    {-workflow_id:required}
} {
    Get the action_id's of all the actions in the workflow.
    
    @param workflow_id   The ID of the workflow

    @return              list of action_id's.

    @author Lars Pind (lars@collaboraid.biz)
} {
    return [workflow::action::fsm::get_ids -workflow_id $workflow_id]
}

ad_proc -public simulation::action::get_element {
    {-action_id {}}
    {-one_id {}}
    {-element:required}
} {
    Return element from information about an action with a given id, including
    simulation info.

    @param action_id The ID of the action

    @param one_id    Same as action_id, just used for consistency across roles/actions/states.

    @param element   The element you want

    @return          The element you asked for

    @author Peter Marklund
    @author Lars Pind (lars@collaboraid.biz)
} {
    if { [empty_string_p $action_id] } {
        if { [empty_string_p $one_id] } {
            error "You must supply either action_id or one_id"
        }
        set action_id $one_id
    } else {
        if { ![empty_string_p $one_id] } {
            error "You can only supply either action_id or one_id"
        }
    }
    get -action_id $action_id -array row
    return $row($element)
}
