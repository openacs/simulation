ad_library {
    API for Simulation templates.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::template {}

#----------------------------------------------------------------------
# Basic Workflow API implementation
#----------------------------------------------------------------------

ad_proc -public simulation::template::edit {
    {-operation "update"}
    {-workflow_id {}}
    {-array {}}
    {-internal:boolean}
} {
    Edit a workflow.

    @param operation    insert, update, delete

    @param workflow_id  For update/delete: The workflow to update or delete. 

    @param array        For insert/update: Name of an array in the caller's namespace with attributes to insert/update.

    @param internal     Set this flag if you're calling this proc from within the corresponding proc 
                        for a particular workflow model. Will cause this proc to not flush the cache 
                        or call workflow::definition_changed_handler, which the caller must then do.

    @return workflow_id
    
    @see workflow::edit
} {
    switch $operation {
        update - delete {
            if { [empty_string_p $workflow_id] } {
                error "You must specify the workflow_id of the workflow to $operation."
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

    # Parse column values
    switch $operation {
        insert - update {
            set update_clauses [list]
            set insert_names [list]
            set insert_values [list]

            # Handle columns in the sim_tasks table
            foreach attr { 
                sim_type suggested_duration
                enroll_type casting_type
                enroll_start enroll_end send_start_note_date case_start case_end
            } {
                if { [info exists row($attr)] } {
                    set varname attr_$attr
                    # Convert the Tcl value to something we can use in the query
                    switch $attr {
                        suggested_duration {
                            if { [empty_string_p $row($attr)] } {
                                set $varname [db_null]
                            } else {
                                set $varname "interval '[db_quote $row($attr)]'"
                            }
                        }
                        default {
                            set $varname $row($attr)
                        }
                    }
                    # Add the column to the insert/update statement
                    switch $attr {
                        enroll_start - enroll_end - send_start_note_date - case_start - case_end {
                            lappend update_clauses "$attr = to_date('[db_quote $row($attr)]', 'YYYY-MM-DD')"
                            lappend insert_names $attr
                            lappend insert_values "to_date('[db_quote $row($attr)]', 'YYYY-MM-DD')"
                        }
                        suggested_duration {
                            if { [empty_string_p $row($attr)] } {
                                lappend update_clauses "$attr = :$varname"
                                lappend insert_names $attr
                                lappend insert_values :$varname
                            } else {
                                lappend update_clauses "$attr = [set $varname]"
                                lappend insert_names $attr
                                lappend insert_values [set $varname]
                            }
                        }
                        default {
                            lappend update_clauses "$attr = :$varname"
                            lappend insert_names $attr
                            lappend insert_values :$varname
                        }
                    }
                    unset row($attr)
                }
            }
            # Handle auxillary rows
            array set aux [list]
            foreach attr { 
                enrolled invited auto-enroll
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
        set workflow_id [workflow::edit \
                           -internal \
                           -operation $operation \
                           -workflow_id $workflow_id \
                           -array row]

        # sim_tasks row
        switch $operation {
            insert {
                lappend insert_names simulation_id
                lappend insert_values :workflow_id

                db_dml insert_workflow "
                    insert into sim_simulations
                    ([join $insert_names ", "])
                    values
                    ([join $insert_values ", "])
                "
            }
            update {
                if { [llength $update_clauses] > 0 } {
                    db_dml update_workflow "
                        update sim_simulations
                        set    [join $update_clauses ", "]
                        where  simulation_id = :workflow_id
                    "
                }
            }
            delete {
                # Handled through cascading delete
            }
        }
        
        # Update sim_party_sim_map table
        foreach map_type { enrolled invited auto-enroll } {
            if { [info exists aux($map_type)] } {
                # Clear out old mappings first
                db_dml clear_old_mappings {
                    delete from sim_party_sim_map
                    where simulation_id = :workflow_id
                      and type = :map_type
                }

                # Map each party
                foreach party_id $aux($map_type) {
                    db_dml map_party_to_template {
                        insert into sim_party_sim_map
                        (simulation_id, party_id, type)
                        values (:workflow_id, :party_id, :map_type)
                    }
                }
                unset aux($map_type)
            }
        }

        if { !$internal_p } {
            workflow::definition_changed_handler -workflow_id $workflow_id
        }
    }

    if { !$internal_p } {
        workflow::flush_cache -workflow_id $workflow_id
    }

    return $workflow_id
}

ad_proc -public simulation::template::get {
    {-workflow_id:required}
    {-array:required}
} {
    Return information about a simulation template.  This is a wrapper around 
    workflow::get, supplementing it with the columns from sim_simulation.

    @param workflow_id ID of simulation template.
    @param array name of array in which the info will be returned
                 Array will contain keys from the tables workflows and sim_simulations.

    @see simulation::template::get_parties
} {
    upvar $array row

    workflow::get -array row -workflow_id $workflow_id

    db_1row select_template {} -column_array local_row
    array set row [array get local_row]
}

ad_proc -public simulation::template::delete {
    {-workflow_id:required}
} {
    Delete a simulation template.

    @author Peter Marklund
} {
    simulation::template::edit -workflow_id $workflow_id -operation delete
}


#----------------------------------------------------------------------
# Additional API implementations
#----------------------------------------------------------------------

ad_proc -public simulation::template::delete_role_group_mappings {
    {-workflow_id}
} {
        db_dml clear_old_group_mappings {
            delete from sim_role_group_map
            where role_id in (select role_id
                              from workflow_roles
                              where workflow_id = :workflow_id
                              )
        }
}

ad_proc -public simulation::template::new_role_group_mapping {
    {-role_id:required}
    {-group_id:required}
    {-group_size:required}
} {
    db_dml map_group_to_role {
        insert into sim_role_group_map (role_id, party_id, group_size)
            values (:role_id, :group_id, :group_size)
    }
}

ad_proc -public simulation::template::get_role_group_mappings {
    {-workflow_id}
    {-array:required}
} {    
    upvar $array roles

    array set roles {}

    db_foreach select_group_mappings {
            select role_id,
            party_id,
            group_size
            from sim_role_group_map
            where role_id in (select role_id
                              from workflow_roles
                              where workflow_id = :workflow_id
                              )
    } {
        set roles($role_id) [list $party_id $group_size]
    }
}
 

ad_proc -public simulation::template::get_parties {
    {-workflow_id:required}
    {-rel_type "auto-enroll"}
} {
    Return a list of parties related to the given simulation.

    @param rel_type The type of relationship of the party to the
                    simulation template. Permissible values are
                    enrolled, invited, and auto-enroll
    
    @return A list of party_id:s
} {
    ad_assert_arg_value_in_list rel_type {enrolled invited auto-enroll}

    return [db_list template_parties {
        select party_id
        from sim_party_sim_map
        where simulation_id = :workflow_id
          and type = :rel_type
    }]
}

ad_proc -public simulation::template::ready_for_casting_p {
    {-workflow_id ""}
    {-role_empty_count ""}
    {-prop_empty_count ""}
} {
    Return 1 if the simulation is ready for casting and 0 otherwise.
    Goes to the database if workflow_id is provided and uses the other
    proc parameters otherwise to do the test.

    @param workflow_id    The id of the simulation to check. The proc
                            will go to the database to get info about the simulation
                            if id is provided.
    @param role_empty_count The number of empty roles for the simulation. Must be
                            provided if workflow_id is not.
    @param prop_empty_count The number of empty properties for the simulation. Must be
                            provided if workflow_id is not.

    @author Peter Marklund
} {
    if { ![empty_string_p $workflow_id] } {
        # workflow_id provided

        set role_empty_count [db_string role_empty_count {
            select count(*) 
              from sim_roles sr,
                   workflow_roles wr
             where sr.role_id = wr.role_id
               and wr.workflow_id = :workflow_id
               and character_id is null
         }]

         set prop_empty_count [db_string prop_empty_count { 
             select count(*) 
              from sim_task_object_map stom,
                   workflow_actions wa
             where stom.task_id = wa.action_id
               and wa.workflow_id = :workflow_id
               and stom.object_id is null
         }]
        
    } else {
        # No workflow_id required
        if { [empty_string_p $role_empty_count] || [empty_string_p $prop_empty_count] } {
            error "When no workflow_id is provided you must provide role_empty_count and prop_empty_count"
        }        
    }

    return [expr [string equal $role_empty_count 0] && [string equal $prop_empty_count 0]]
}

ad_proc -public simulation::template::associate_object {
    -template_id:required
    -object_id:required
} {
    Associate an object with a simulation template.  Succeeds if the record is added or already exists.
} {
      set exists_p [db_string row_exists {
          select count(*) 
            from sim_workflow_object_map
          where workflow_id =  :template_id
            and object_id = :object_id
      }]

    if { ! $exists_p } {
        db_dml add_object_to_workflow_insert {
            insert into sim_workflow_object_map
            values (:template_id, :object_id)
        }
    }
}

ad_proc -public simulation::template::dissociate_object {
    -template_id:required
    -object_id:required
} {
    Dissociate an object with a simulation template
} {
    db_dml remove_object_from_workflow_delete {
            delete from sim_workflow_object_map
            where workflow_id =  :template_id
              and object_id = :object_id
    }
    # no special error handling because the delete is pretty safe
}

ad_proc -public simulation::template::start {
     {-workflow_id:required}
} {
    Make a simulation go live immediately. Does enrollment and
    casting and sets sim_type attribute to live_sim.

    @author Peter Marklund
} {
    simulation::template::get -workflow_id $workflow_id -array simulation

    db_transaction {
        # Move enroll_end to now if it's in the future
        set today [db_string select_today {
            select to_char(current_timestamp, 'YYYY-MM-DD')
        }]
        if { [clock scan $today] < [clock scan $simulation(enroll_end)] } {
            set simulation_edit(enroll_date) $today
        }

        # Set start_date to now
        set simulation_edit(start_date) $today

        # Auto enroll users in auto-enroll groups
        set simulation_edit(enrolled) [list]
        foreach party_id [simulation::template::get_parties -workflow_id $workflow_id] {
            set simulation_edit(enrolled) [concat $simulation_edit(enrolled) \
                                                   [db_list party_users {
                                                       select u.user_id
                                                       from party_approved_member_map pamm,
                                                       users u
                                                       where pamm.party_id = :party_id
                                                       and pamm.member_id = u.user_id
                                                   }]]
        }

        # Change sim_type to live_sim
        set simulation_edit(sim_type) live_sim
            
        simulation::template::edit -workflow_id $workflow_id -array simulation_edit

        simulation::template::cast -workflow_id $workflow_id
    }
}

ad_proc -public simulation::template::cast {
     {-workflow_id:required}
} {
    Takes a mapped simulation template and converts it into a cast simulation
    with simulation cases. This procedure expects to be called after enrollment is complete.

    TODO: agent support

    TODO: taking actor type into account

    TODO: other casting_type values than auto

    @author Peter Marklund
} {
    # Assuming here that mapped parties with type enrolled are users
    set user_list [db_list select_users {
        select party_id
        from sim_party_sim_map
        where type = 'enrolled'
    }]
    set total_n_users [llength $user_list]

    simulation::template::get_role_mappings -workflow_id $workflow_id -array roles

    set n_users_per_case 0
    foreach role_id [array names roles] {
        set n_users_per_case [expr $n_users_per_case + [lindex $roles($role_id) 1]]
    }

    set mod_n_users [expr $total_n_users % $n_users_per_case]
    set n_cases [expr ($total_n_users - $mod_n_users) / $n_users_per_case]

    if { $mod_n_users == "0" } {
        # No rest in dividing, the cases add up nicely
        
    } else {
        # We are missing mod_n_users to fill up the simulation. Create a new simulation
        # for those students.
        set n_cases [expr $n_cases + 1]
    }

    # Create the cases and for each case assign roles to parties
    set users_start_index 0
    for { set case_counter 0 } { $case_counter < $n_cases } { incr case_counter } {
        # TODO: what should object_id be here?
        set object_id [ad_conn package_id]
        set case_id [workflow::case::new \
                         -workflow_id $workflow_id \
                         -object_id $object_id]

        # Assign a group of users to each role in the case
        set party_array_list [list]
        foreach role_id [array names roles] {
            set role_short_name [workflow::role::get_element -role_id $role_id -element short_name]

            set users_end_index [expr $users_start_index + $groupings_array($role_id) - 1]

            set parties_list [lrange $user_list $users_start_index $users_end_index]

            lappend parties_array_list $role_short_name $parties_list

            set users_start_index [expr $users_end_index + 1]
        }

        workflow::case::role::assign \
            -case_id $case_id \
            -array $parties_array_list \
            -replace
    }
}




#----------------------------------------------------------------------
# Simple workflow wrappers
#----------------------------------------------------------------------

ad_proc -public simulation::template::new {
    {-pretty_name:required}
    {-short_name {}}
    {-sim_type "dev_template"}
    {-suggested_duration ""}
    {-package_key:required}
    {-object_id:required}
} {
    Create a new simulation template.  TODO: need better tests for duration before passing it into the database.

    @return The workflow_id of the created simulation.

    @author Peter Marklund
} {
    # Wrapper for simulation::template::edit
    
    foreach elm { pretty_name short_name sim_type suggested_duration package_key object_id } {
        set row($elm) [set $elm]
    }
    
    set workflow_id [simulation::template::edit \
                         -operation "insert" \
                         -array row]
                     
    return $workflow_id
}

ad_proc -public simulation::template::generate_spec {
    {-workflow_id:required}
} {
    Generate a spec for a workflow in array list style.
    
    @param  workflow_id   The id of the workflow to generate a spec for.
    @return The spec for the workflow.

    @author Lars Pind (lars@collaboraid.biz)
    @see workflow::new
} {
    set spec [workflow::generate_spec \
                  -workflow_id $workflow_id \
                  -handlers {
                      roles simulation::role 
                      actions simulation::action
                      states workflow::state::fsm
                  }]

    # TODO: Add sim_template attributes to the spec

    return $spec
}

ad_proc -public simulation::template::new_from_spec {
    {-package_key {}}
    {-object_id {}}
    {-spec:required}
    {-array {}}
} {
    Create new simulation template from a spec. Basically encodes the handlers to use.
} {
    # Wrapper for workflow::new_from_spec

    if { ![empty_string_p $array] } {
        upvar 1 $array row
        set array row
    } 
    return [workflow::new_from_spec \
                -package_key $package_key \
                -object_id $object_id \
                -spec $spec \
                -array $array \
                -workflow_handler "simulation::template" \
                -handlers {
                    roles simulation::role 
                    states workflow::state::fsm
                    actions simulation::action
                }]
}

ad_proc -public simulation::template::clone {
    {-workflow_id:required}
    {-package_key {}}
    {-object_id {}}
    {-array {}}
} {
    Clones an existing simulation template. The clone must belong to either a package key or an object id.

    @param object_id     The id of an ACS Object indicating the scope the workflow. 
                         Typically this will be the id of a package type or a package instance
                         but it could also be some other type of ACS object within a package, for example
                         the id of a bug in the Bug Tracker application.

    @param package_key   A package to which this workflow belongs

    @param array         The name of an array in the caller's namespace. Values in this array will 
                         override workflow attributes of the workflow being cloned.

    @author Lars Pind (lars@collaboraid.biz)
    @see workflow::new
} {
    # Wrapper for workflow::clone

    if { ![empty_string_p $array] } {
        upvar 1 $array row
        set array row
    } 
    return [workflow::clone \
                -workflow_id $workflow_id \
                -package_key $package_key \
                -object_id $object_id \
                -array $array \
                -workflow_handler simulation::template]

    return $workflow_id
}
