ad_library {
    API for Simulation templates.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::template {}

ad_proc -public simulation::template::new {
    {-short_name:required}
    {-pretty_name:required}
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
        set short_name [util_text_to_url -replacement "_" $short_name]

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

ad_proc -private simulation::template::insert_sim {
    {-workflow_id:required}
    {-sim_type:required}
    {-suggested_duration:required}
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
        values ('$workflow_id', '$sim_type', interval '$suggested_duration')"            
    }
}

ad_proc -public simulation::template::edit {
    {-workflow_id:required}
    {-short_name:required}
    {-pretty_name:required}
    {-sim_type:required}
    {-suggested_duration ""}
    {-package_key:required}
    {-object_id:required}
} {
    Edit a new simulation template.  TODO: need better tests for duration before passing it into the database.

    @return nothing

    @author Joel Aufrecht
} {
    db_transaction {

        # TODO: this should be in a new API call, workflow::edit

        db_dml edit_workflow "
            update workflows
               set short_name=:short_name,
                   pretty_name=:pretty_name
             where workflow_id=:workflow_id"

        if { [empty_string_p $suggested_duration] } {
            db_dml edit_sim {
                update sim_simulations
                   set sim_type=:sim_type, 
                       suggested_duration = null
                 where simulation_id=:workflow_id
            }
        } else {
            db_dml edit_sim "
                update sim_simulations
                   set sim_type=:sim_type,
                       suggested_duration=(interval '$suggested_duration')
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
