ad_page_contract {
    Delete a role.

    Determine if a role has tasks.  If show, display all those 
    tasks and ask for confirmation.  If not, delete on the first pass.
} {
    {confirm_p:boolean "f"}
    role_id:integer
    {return_url "."}
}

set package_id [ad_conn package_id]
set num_of_tasks [db_string task_count "
select count(*) 
  from workflow_actions wa,
       sim_tasks st
 where st.task_id = wa.action_id
   and wa.assigned_role = :role_id
    or st.recipient = :role_id
   "
                  ]
if { [template::util::is_true $confirm_p] || $num_of_tasks == 0 } {
    permission::require_write_permission -object_id $role_id    
    simulation::role::delete -role_id $role_id
    ad_returnredirect $return_url
}

workflow::role::get -role_id $role_id -array role_array
set name $role_array(pretty_name)
set workflow_id $role_array(workflow_id)
workflow::get -workflow_id $workflow_id -array sim_template_array    

set page_title "Delete $name"
set context [list [list "." "Sim Templates"] [list "template-edit?workflow_id=$workflow_id" "$sim_template_array(pretty_name)"] $page_title]    

set delete_url [export_vars -base [ad_conn url] { role_id return_url { confirm_p 1 } }]
set cancel_url $return_url
