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
    {-ready_p "f"}
    {-suggested_duration ""}
    {-package_key:required}
    {-object_id:required}
} {
    Create a new simulation template.  TODO: need better tests for duration before passing it into the database.

    @return The workflow_id of the created simulation.

    @author Peter Marklund
} {
    if { ![exists_and_not_null ready_p] } {
        set ready_p "f"
    }
    db_transaction {
        set workflow_id [workflow::new \
                             -short_name $short_name \
                             -pretty_name $pretty_name \
                             -package_key $package_key \
                             -object_id $object_id]
        
        # TODO: this step should be rendered obsolete by updates to workflow
        #       and then this step should be removed
        # create a dummy action with initial action setting because
        # workflow::get doesn't work on bare workflows
        workflow::action::fsm::new \
            -initial_action_p t \
            -workflow_id $workflow_id \
            -short_name "dummy action" \
            -pretty_name "dummy action"

        set suggested_duration [string trim $suggested_duration]
        if { [empty_string_p $suggested_duration] } {
            db_dml new_sim {
                insert into sim_simulations
                (simulation_id, ready_p)
                values (:workflow_id, :ready_p)
            }
        } else {
            db_dml new_sim "
            insert into sim_simulations
            (simulation_id, ready_p, suggested_duration)
            values ('$workflow_id', '$ready_p', interval '$suggested_duration')"            
        }
    }

    return $workflow_id
}

ad_proc -public simulation::template::edit {
    {-workflow_id:required}
    {-short_name:required}
    {-pretty_name:required}
    {-ready_p "f"}
    {-suggested_duration ""}
    {-package_key:required}
    {-object_id:required}
} {
    Edit a new simulation template.  TODO: need better tests for duration before passing it into the database.

    @return nothing

    @author Joel Aufrecht
} {
    if { ![exists_and_not_null ready_p] } {
        set ready_p "f"
    }
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
                   set ready_p=:ready_p, 
                       suggested_duration = null
                 where simulation_id=:workflow_id
            }
        } else {
            db_dml edit_sim "
                update sim_simulations
                   set ready_p=:ready_p, 
                       suggested_duration=(interval '$suggested_duration')
                 where simulation_id=:workflow_id
            "
        }
    }
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
