ad_page_contract {
    Move workflow object up/down. Handles states, actions, roles.
} {
    type:notnull
    state_id:optional
    action_id:optional
    role_id:optional
    {direction down}
    {return_url "."}
}

# 1. find the sort_order of the object before or after this one
# 2. set the sort order of this object to that object's sort order (if up), or that + 1 (if down)
# 3. 

switch $type {
    state {
        set workflow_id [workflow::state::fsm::get_element -state_id $state_id -element workflow_id]
        
        set state_ids [workflow::state::fsm::get_ids -workflow_id $workflow_id]
        
        set cur_index [lsearch -exact $state_ids $state_id]
        
        switch $direction {
            up {
                set new_index [expr $cur_index - 1]
            }
            down {
                set new_index [expr $cur_index + 1]
            }
        }
        
        if { $new_index >= 0 && $new_index < [llength $state_ids] } {
            set new_sort_order [workflow::state::fsm::get_element -state_id [lindex $state_ids $new_index] -element sort_order]
            
            if { [string equal $direction "down"] } {
                set new_sort_order [expr $new_sort_order + 1]
            }
            
            set row(sort_order) $new_sort_order

            workflow::state::fsm::edit \
                -state_id $state_id \
                -workflow_id $workflow_id \
                -array row
        }
    }
    role {

    }
    action {
        
    }
}



ad_returnredirect $return_url
