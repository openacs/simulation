ad_library {
    API for Simulation actions.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::action {}

ad_proc -public simulation::action::edit {
    {-action_id:required}
    {-workflow_id {}}
    {-array:required}
    {-internal:boolean}
} {
    Edit an action.  Mostly a wrapper for FSM, plus some simulation-specific stuff.
} {
    upvar 1 $array org_row
    array set row [array get org_row]
    
    db_transaction {
        if { [info exists row(recipient_role)] } {
            set recipient_role_id [workflow::role::get_id \
                                       -workflow_id $workflow_id \
                                       -short_name $row(recipient_role)]
            
            db_dml edit_sim_role {
                update sim_tasks
                set    recipient = :recipient_role_id
                where  task_id = :action_id
            }

            unset row(recipient_role)
        }

        workflow::action::fsm::edit \
            -internal \
            -action_id $action_id \
            -workflow_id $workflow_id \
            -array row
        
        if { !$internal_p } {
            workflow::definition_changed_handler -workflow_id $workflow_id
        }
    }

    if { !$internal_p } {
        workflow::flush_cache -workflow_id $workflow_id
    }
}
