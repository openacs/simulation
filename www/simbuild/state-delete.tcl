ad_page_contract {
    Delete a state

} {
    {confirm_p:boolean "f"}
    state_id:integer
    {return_url ""}
}

set package_id [ad_conn package_id]

set workflow_id [workflow::state::fsm::get_element -state_id $state_id -element workflow_id]

workflow::state::fsm::get -state_id $state_id -array state_array

set name $state_array(pretty_name)
set workflow_id $state_array(workflow_id)

set tasks [db_list enabled_tasks "
select action_id 
from workflow_fsm_action_en_in_st wfa, 
    workflow_fsm_states wfs
where wfa.state_id = wfs.state_id
    and wfs.state_id = :state_id
    and wfs.workflow_id = :workflow_id
"
	   ]

set tasks [concat $tasks [db_list next_state_tasks "
select wa.action_id
from workflow_fsm_actions wfa,
    workflow_actions wa
where wa.action_id = wfa.action_id
    and wfa.new_state = :state_id
    and wa.workflow_id = :workflow_id
"
	       ]
	   ]

set num_of_tasks [llength $tasks]

if { [empty_string_p $return_url] } {
    set return_url [export_vars -base template-edit { workflow_id }]
}

if { [template::util::is_true $confirm_p] || $num_of_tasks == 0 } {
    permission::require_write_permission -object_id $workflow_id

    # confirm_p is true and we have tasks
    if { $num_of_tasks > 0 } {
	foreach task $tasks {
	    simulation::action::edit -operation delete -action_id $task
	}
    }

    workflow::state::fsm::edit -operation "delete" -state_id $state_id

    # Let's mark this template edited
    set sim_type "dev_template"

    ad_returnredirect [export_vars -base "template-sim-type-update" { workflow_id sim_type return_url }]

}


workflow::get -workflow_id $workflow_id -array sim_template_array

set page_title "Delete $name"
set context [list [list "." "Sim Templates"] [list "template-edit?workflow_id=$workflow_id" "$sim_template_array(pretty_name)"] $page_title]    

set delete_url [export_vars -base [ad_conn url] { state_id return_url { confirm_p 1 } }]
set cancel_url $return_url