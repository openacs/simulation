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
    {-package_key:required}
    {-object_id:required}
} {
    Create a new simulation template.

    @return The workflow_id of the created simulation.

    @author Peter Marklund
} {
    set workflow_id [workflow::new \
                         -short_name $short_name \
                         -pretty_name $pretty_name \
                         -package_key $package_key \
                         -object_id $object_id]

    # create a dummy action with initial action setting because
    # workflow::get doesn't work on bare workflows
    workflow::action::fsm::new \
        -initial_action_p t \
        -workflow_id $workflow_id \
        -short_name "dummy action" \
        -pretty_name "dummy action"

    return $workflow_id
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
