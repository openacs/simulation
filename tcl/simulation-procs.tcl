ad_library {
    API for Simulation.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation {}
namespace eval simulation::action {}
namespace eval simulation::object_type {}
namespace eval simulation::template {}

ad_proc -public simulation::object_type::get_options {
} {
    Generate a list of object types formatted as an option list for form-builder's widgets. foo.
} {
    set sim_types { sim_character sim_prop sim_location sim_stylesheet image }

    return [db_list_of_lists object_types "
        select ot.pretty_name,
               ot.object_type
          from acs_object_types ot
         where ot.object_type in ('[join $sim_types "','"]')
    "]
}

ad_proc -public simulation::action::edit {
    {-action_id:required}
    {-sort_order {}}
    {-short_name:required}
    {-pretty_name:required}
    {-pretty_past_tense {}}
    {-edit_fields {}}
    {-allowed_roles {}}
    {-assigned_role {}}
    {-privileges {}}
    {-enabled_states {}}
    {-assigned_states {}}
    {-new_state {}}
    {-callbacks {}}
    {-always_enabled_p f}
    {-initial_action_p f}
    {-recipient_role:required {}}
} {
    Edit an action.  Mostly a wrapper for fsm, plus some simulation-specific stuff.
} {

    # should call API, but API doesn't exist yet
    # deferring at the moment since we're only changing two fields in this
    # prototype UI anyway.  But it would look like this:

    #    workflow::action::fsm::edit \
    #       -workflow_id $workflow_id
    #      -short_name $name \
    #       -pretty_name $name \
    #       -assigned_role $assigned_role

    set workflow_id [workflow::action::get_workflow_id -action_id $action_id]

    set assigned_role_id [workflow::role::get_id -workflow_id $workflow_id  -short_name $assigned_role ]
    set recipient_role_id [workflow::role::get_id -workflow_id $workflow_id  -short_name $recipient_role ]

    db_transaction {
        db_dml edit_workflow_action {
            update workflow_actions
               set short_name = :short_name,
                   pretty_name = :pretty_name,
                   assigned_role = :assigned_role_id
             where action_id = :action_id
        }

        db_dml edit_sim_role {
            update sim_tasks
               set recipient = :recipient_role_id
             where task_id = :action_id
        }
    }

    workflow::action::flush_cache -workflow_id $workflow_id
}

ad_proc -public simulation::template::associate_object {
    -template_id:required
    -object_id:required
} {
    Associate an object with a simulation template.  Succeeds if the record is added or already exists.
} {

    with_catch errmsg {
        db_dml add_object_to_workflow_insert {
            insert into sim_workflow_object_map
            values (:template_id, :object_id)
        }
    } { 
        # can only be 0 or 1 due to table constraints
        set exists_p [db_string row_exists {
            select count(*) 
              from sim_workflow_object_map
            where workflow_id =  :template_id
              and object_id = :object_id
        }]
        
        if { $exists_p } {
            # the record already exists. Return normally
        } {
            # the record didn't exist, so pass on the error
            global errorInfo 
            error $errmsg $errorInfo
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
