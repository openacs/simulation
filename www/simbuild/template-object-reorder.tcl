ad_page_contract {
    Move workflow object up/down. Handles states, actions, roles.
} {
    type:notnull
    state_id:optional
    action_id:optional
    role_id:optional
    parent_action_id:optional
    {direction down}
    {return_url "."}
}

# 1. find the sort_order of the object before or after this one
# 2. set the sort order of this object to that object's sort order (if up), or that + 1 (if down)
# 3. 

switch $type {
    state {
        set object_id $state_id
        set workflow_id [workflow::state::fsm::get_element \
			     -state_id $state_id -element workflow_id]
	# Use parent_action_id if we're not on the top-level
	if { [exists_and_not_null parent_action_id] } {
	    set all_ids [workflow::state::fsm::get_ids \
			     -workflow_id $workflow_id \
			     -parent_action_id $parent_action_id]
	} else {
	    set all_ids [workflow::state::fsm::get_ids -workflow_id $workflow_id]
	}
    }
    role {
        set object_id $role_id
        set workflow_id [workflow::role::get_element -role_id $role_id -element workflow_id]

	# Roles are only available on a top-level workflow so we don't need the 
	# parent_action_id here
        set all_ids [workflow::role::get_ids -workflow_id $workflow_id]
    }
    action {
        set object_id $action_id
        set workflow_id [workflow::action::get_element -action_id $action_id -element workflow_id]

	# Use parent_action_id if we're not on the top-level     
	if { [exists_and_not_null parent_action_id] } {
	    set all_ids [workflow::action::get_ids -workflow_id $workflow_id \
			    -parent_action_id $parent_action_id]
	} else {
	    set all_ids [workflow::action::get_ids -workflow_id $workflow_id]
	}        
    }
    default {
        error "Invalid type, $type, only implemented for 'state', 'role', and 'action'."
    }
}
        
set cur_index [lsearch -exact $all_ids $object_id]

switch $direction {
    up {
        set new_index [expr $cur_index - 1]
    }
    down {
        set new_index [expr $cur_index + 1]
    }
    default {
        error "Invalid direction. Valid directions are 'up', 'down'"
    }
}

if { $new_index >= 0 && $new_index < [llength $all_ids] } {
    switch $type {
        state {
            set new_sort_order [workflow::state::fsm::get_element -state_id [lindex $all_ids $new_index] -element sort_order]
        }
        role {
            set new_sort_order [workflow::role::get_element -role_id [lindex $all_ids $new_index] -element sort_order]
        }
        action {
            set new_sort_order [workflow::action::get_element -action_id [lindex $all_ids $new_index] -element sort_order]
        }
    }
            
    if { [string equal $direction "down"] } {
        set new_sort_order [expr $new_sort_order + 1]
    }
    
    set row(sort_order) $new_sort_order
    
    switch $type {
        state {
            workflow::state::fsm::edit \
                -state_id $state_id \
                -workflow_id $workflow_id \
                -array row
        }
        role {
            workflow::role::edit \
                -role_id $role_id \
                -workflow_id $workflow_id \
                -array row
        }
        action {
            workflow::action::edit \
                -action_id $action_id \
                -workflow_id $workflow_id \
                -array row
        }
    }
}

# Let's mark this template edited
set sim_type "dev_template"

ad_returnredirect [export_vars -base "template-sim-type-update" { workflow_id sim_type return_url }]
