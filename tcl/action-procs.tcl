ad_library {
    API for Simulation actions.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::action {}


# TODO: add simulation::action::new

ad_proc -public simulation::action::edit {
    {-action_id:required}
    {-workflow_id {}}
    {-array:required}
    {-internal:boolean}
} {
    Edit an action.  Mostly a wrapper for FSM, plus some simulation-specific stuff.

    Available attributes: recipient (role_id), recipient_role (role short_name), attachment_num
} {
    upvar 1 $array org_row
    if { ![array exists org_row] } {
        error "Array $array does not exist or is not an array"
    }
    array set row [array get org_row]

    set set_clauses [list]

    # Handle attributes in sim_tasks table
    if { [info exists row(recipient_role)] } {
        if { [empty_string_p $row(recipient_role)] } {
            set row(recipient) [db_null]
        } else {
            # Get role_id by short_name
            set row(recipient) [workflow::role::get_id \
                                            -workflow_id $workflow_id \
                                            -short_name $row(recipient_role)]
        }
        unset row(recipient_role)
    }

    foreach attr { 
        recipient attachment_num
    } {
        if { [info exists row($attr)] } {
            set varname attr_$attr
            # Convert the Tcl value to something we can use in the query
            set $varname $row($attr)
            # Add the column to the SET clause
            lappend set_clauses "$attr = :$varname"
            unset row($attr)
        }
    }

    db_transaction {
        if { [llength $set_clauses] > 0 } {
            db_dml edit_sim_role "
                update sim_tasks
                set    [join $set_clauses ", "]
                where  task_id = :action_id
            "
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
