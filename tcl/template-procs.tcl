ad_library {
    API for Simulation templates.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::template {}

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
    db_transaction {
        set workflow_id [workflow::new \
                             -short_name $short_name \
                             -pretty_name $pretty_name \
                             -package_key $package_key \
                             -object_id $object_id]
        
        insert_sim \
            -workflow_id $workflow_id \
            -sim_type $sim_type \
            -suggested_duration $suggested_duration
    }

    return $workflow_id
}

ad_proc -public simulation::template::new_from_spec {
    {-package_key {}}
    {-object_id {}}
    {-spec:required}
    {-array {}}
} {
    Create a new simulation template for a spec.

    @return The workflow_id of the created simulation.

    @author Lars Pind
} {
    if { ![empty_string_p $array] } {
        upvar 1 $array row
        set array row
    } 

    db_transaction {

        set workflow_id [workflow::fsm::new_from_spec \
                             -package_key $package_key \
                             -object_id $object_id \
                             -spec $spec \
                             -array $array]
        
        insert_sim \
            -workflow_id $workflow_id
    }

    return $workflow_id
}

ad_proc -private simulation::template::insert_sim {
    {-workflow_id:required}
    {-sim_type "dev_template"}
    {-suggested_duration {}}
} {
    Internal proc for inserting values into the sim_simulations
    table that are set prior to a template being mapped.
    
    @author Peter Marklund
} {
    set suggested_duration [string trim $suggested_duration]
    if { [empty_string_p $suggested_duration] } {
        db_dml new_sim {
            insert into sim_simulations
            (simulation_id, sim_type)
            values (:workflow_id, :sim_type)
        }
    } else {
        db_dml new_sim "
        insert into sim_simulations
        (simulation_id, sim_type, suggested_duration)
        values (:workflow_id, :sim_type, interval '[db_quote $suggested_duration]')"            
    }
}

ad_proc -public simulation::template::edit {
    {-workflow_id:required}
    {-array:required}
} {
    Edit a new simulation template.  TODO: need better tests for duration before passing it into the database.
    
    @param workflow_id The id of the template to edit.
    @param array The name of an array in the callers scope that contains properties to edit.

    @return nothing

    @author Joel Aufrecht
} {
    upvar $array edit_array

    db_transaction {

        # Update workflows table

        # TODO: this should be in a new API call, workflow::edit
        set set_clauses [list]
        foreach col {short_name pretty_name package_key object_id description} {
            if { [info exists edit_array($col)] } {
                lappend set_clauses "$col = :$col"
                set $col $edit_array($col)
            }
        }

        if { [llength $set_clauses] > 0 } {
            db_dml edit_workflow "
            update workflows
               set [join $set_clauses ", "]
             where workflow_id=:workflow_id"
        }

        # Update sim_simulations table

        set set_clauses [list]
        foreach col {sim_type suggested_duration} {
            if { [info exists edit_array($col)] } {
                if { [string equal $col suggested_duration] } {
                    # Suggested duration needs special interval update syntax
                    if { [empty_string_p $edit_array($col)] } {
                        lappend set_clauses "$col = null"
                    } else {
                        lappend set_clauses "$col = (interval '$edit_array($col)')"
                    }
                } else {
                    lappend set_clauses "$col = :$col"
                }

                set $col $edit_array($col)
            }
        }

        if { [llength $set_clauses] > 0 } {
            db_dml edit_sim "
                    update sim_simulations
                    set [join $set_clauses ", "]
                    where simulation_id=:workflow_id
                "
        }
    }
}

ad_proc -public simulation::template::instantiate_edit {
    {-workflow_id:required}
    {-enroll_start:required}
    {-enroll_end:required}
    {-notification_date:required}
    {-case_start:required}
    {-case_end:required}
    {-enroll_type:required}
    {-casting_type:required}
    {-parties:required}    
} {
    Edit properties of a simulation set during instantiation.
    
    TODO: merge this proc with ::edit?

    @author Peter Marklund
} {
    db_dml update_instantiate_template {
        update sim_simulations
        set enroll_start = to_date(:enroll_start, 'YYYY-MM-DD'),
        enroll_end = to_date(:enroll_end, 'YYYY-MM-DD'),
        send_start_note_date = to_date(:notification_date, 'YYYY-MM-DD'),
        case_start = to_date(:case_start, 'YYYY-MM-DD'),
        case_end = to_date(:case_end, 'YYYY-MM-DD'),
        enroll_type = :enroll_type,
        casting_type = :casting_type
        where simulation_id = :workflow_id
    }

    # Clear out old mappings first
    db_dml clear_old_mappings {
        delete from sim_party_sim_map
        where simulation_id = :workflow_id
    }

    foreach party_id $parties {
        db_dml map_party_to_template {
            insert into sim_party_sim_map
            (simulation_id, party_id)
            values (:workflow_id, :party_id)
        }
    }
}

ad_proc -public simulation::template::clone {
    {-workflow_id:required}
    {-package_key {}}
    {-object_id {}}
    {-array {}}
} {
    Create a new simulation template which is a clone of the template with
    given id. The clone will be mapped to the package of the current request.

    @param workflow_id The id of the template that you wish to clone.
    @param pretty_name The pretty name of the clone you are creating.
    
    @return The id of the clone.

    @author Peter Marklund
} {
    if { ![empty_string_p $array] } {
        upvar 1 $array row
        set array row
    }

    db_transaction {

        # If we set object_id here and leave short_name unchanged we
        # get a unique constraint violation
        set clone_workflow_id [workflow::fsm::clone \
                                   -workflow_id $workflow_id \
                                   -package_key $package_key \
                                   -object_id $object_id \
                                   -array $array]
        
        # Add the role_id:s to the sim_roles table
        set role_id_list [workflow::get_roles -workflow_id $clone_workflow_id]
        foreach role_id $role_id_list {
            db_dml insert_sim_role {
                insert into sim_roles (role_id) values (:role_id)
            }
        }
        
        # Clone the values in the simulation table
        simulation::template::get -workflow_id $workflow_id -array workflow

        # Allow overriding of sim_type and duration
        if { ![empty_string_p $array] } {
            foreach name [array names row] {
                set workflow($name) $row($name)
            }
        }

        insert_sim \
            -workflow_id $clone_workflow_id \
            -sim_type $workflow(sim_type) \
            -suggested_duration $workflow(suggested_duration)
    }

    return $clone_workflow_id
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
} {
    upvar $array row

    db_1row select_template {} -column_array row
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

ad_proc -public simulation::template::get_workflow_id_from_action {
    {-action_id:required}
} {
    Given an action_id, return the workflow_id

    @param action_id ID of action in workflow
} {
    return [db_string select_workflow_id {
        select wa.workflow_id
          from workflow_actions wa
         where wa.action_id = :action_id
    }]
}

ad_proc -public simulation::template::delete {
    {-workflow_id:required}
} {
    Delete a simulation template.

    @author Peter Marklund
} {
    workflow::delete -workflow_id $workflow_id
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
