ad_library {
    API for Simulation roles.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::role {}

ad_proc -public simulation::role::edit {
    {-operation "update"}
    {-role_id {}}
    {-workflow_id {}}
    {-array {}}
    {-internal:boolean}
    {-no_complain:boolean}
} {
    Edit a role. 

    @param operation    insert, update, delete

    @param role_id      For update/delete: The role to update or delete. 
                        For insert: Optionally specify a pre-generated role_id for the role.

    @param workflow_id  For update/delete: Optionally specify the workflow_id. If not specified, we will execute a query to find it.
                        For insert: The workflow_id of the new role.
    
    @param array        For insert/update: Name of an array in the caller's namespace with attributes to insert/update.

    @param internal     Set this flag if you're calling this proc from within the corresponding proc 
                        for a particular workflow model. Will cause this proc to not flush the cache 
                        or call workflow::definition_changed_handler, which the caller must then do.

    @param no_complain  Silently ignore extra attributes that we don't know how to handle. 

    @return role_id
    
    @see workflow::role::fsm::edit
} {
    switch $operation {
        update - delete {
            if { [empty_string_p $role_id] } {
                error "You must specify the role_id of the role to $operation."
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
        update {
            if { [empty_string_p $workflow_id] } {
                set workflow_id [workflow::role::get_element \
                                     -role_id $role_id \
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

            # Handle columns in the sim_roles table
            foreach attr { 
                character_id users_per_case
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
        }
    }

    db_transaction {
        # Base row
        set role_id [workflow::role::edit \
                         -internal \
                         -operation $operation \
                         -role_id $role_id \
                         -workflow_id $workflow_id \
                         -array row]

        # sim_roles row
        switch $operation {
            insert {
                lappend insert_names role_id
                lappend insert_values :role_id

                db_dml insert_role "
                    insert into sim_roles
                    ([join $insert_names ", "])
                    values
                    ([join $insert_values ", "])
                "
            }
            update {
                if { [llength $update_clauses] > 0 } {
                    db_dml update_role "
                        update sim_roles
                        set    [join $update_clauses ", "]
                        where  role_id = :role_id
                    "
                }
            }
            delete {
                # Handled through cascading delete
            }
        }
        
        if { !$internal_p } {
            workflow::definition_changed_handler -workflow_id $workflow_id
        }
    }

    if { !$internal_p } {
        workflow::flush_cache -workflow_id $workflow_id
    }

    return $role_id
}

ad_proc -public simulation::role::get {
    {-local_only:boolean}
    {-role_id:required}
    {-array:required}
} {
    Get information about a simulation role

    @param local_only   Set this to only get the attributes from the simulation extension table, 
                        not the ones derived from workflow::role
} {
    upvar 1 $array row

    if { !$local_only_p } {
        workflow::role::get -role_id $role_id -array row
    }

    db_1row select_sim_role {
        select character_id,
               users_per_case
        from   sim_roles
        where  role_id = :role_id
    } -column_array local_row

    array set row [array get local_row]
}

ad_proc -public simulation::role::get_element {
    {-role_id {}}
    {-one_id {}}
    {-element:required}
} {
    Return a single element from the information about a role.

    @param role_id  The id of the role to get an element for.

    @param one_id   Same as role_id, just used for consistency across roles/actions/states.

    @return element The element you asked for

    @author Lars Pind (lars@collaboraid.biz)
} {
    if { [empty_string_p $role_id] } {
        if { [empty_string_p $one_id] } {
            error "You must supply either role_id or one_id"
        }
        set role_id $one_id
    } else {
        if { ![empty_string_p $one_id] } {
            error "You can only supply either role_id or one_id"
        }
    }

    get -role_id $role_id -array row
    return $row($element)
}

ad_proc -private simulation::role::get_ids {
    {-all:boolean}
    {-workflow_id:required}
    {-parent_action_id {}}
} {
    Get the IDs of all the roles in the right order.

    @param workflow_id The id of the workflow to delete.

    @return A list of role IDs.

    @author Lars Pind (lars@collaboraid.biz)
} {
    return [workflow::role::get_ids -all=$all_p -workflow_id $workflow_id -parent_action_id $parent_action_id]
}

ad_proc -private simulation::role::generate_spec {
    {-role_id {}}
    {-one_id {}}
} {
    Generate the spec for an individual simulation task definition.

    @param role_id The id of the role to generate spec for.

    @param one_id    Same as role_id, just used for consistency across roles/roles/states.

    @return spec     The roles spec

    @author Lars Pind (lars@collaboraid.biz)
} {
    if { [empty_string_p $role_id] } {
        if { [empty_string_p $one_id] } {
            error "You must supply either role_id or one_id"
        }
        set role_id $one_id
    } else {
        if { ![empty_string_p $one_id] } {
            error "You can only supply either role_id or one_id"
        }
    }

    # Get parent spec
    array set row [workflow::role::generate_spec -role_id $role_id]
    
    # Get local spec, remove unwanted entries
    get -role_id $role_id -array local_row -local_only

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
