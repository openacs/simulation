ad_library {
    API for Simulation actions.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::action {}

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
    {-description {}}
    {-description_mime_type {}}
} {
    Edit an action.  Mostly a wrapper for fsm, plus some simulation-specific stuff.
} {

    # should call API, but API doesn't exist yet
    # deferring at the moment since we're only changing two fields in this
    # prototype UI anyway.  But it would look like this:

    #    workflow::action::fsm::edit \
    #       -workflow_id $workflow_id
    #       -short_name $name \
    #       -pretty_name $name \
    #       -assigned_role $assigned_role

    
    

    set workflow_id [workflow::action::get_workflow_id -action_id $action_id]

    

    db_transaction {
        foreach col { short_name pretty_name assigned_role description description_mime_type } {
            set action_array($col) [set $col]
        }
        
        workflow::action::fsm::edit \
            -action_id $action_id \
            -array action_array
        
        set recipient_role_id [workflow::role::get_id -workflow_id $workflow_id -short_name $recipient_role]
        db_dml edit_sim_role {
            update sim_tasks
               set recipient = :recipient_role_id
             where task_id = :action_id
        }
    }

    workflow::definition_changed_handler -workflow_id $workflow_id
    workflow::action::flush_cache -workflow_id $workflow_id
}
