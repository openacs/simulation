ad_page_contract {
    Show all task descriptions for editing.

    @author Joel Aufrecht
} {
    workflow_id:integer
}

set user_id [auth::require_login]

set page_title "Edit Task Descriptions"
set context [list [list "." "SimInst"] $page_title]
set old_name [workflow::get_element -workflow_id $workflow_id -element pretty_name]
acs_user::get -user_id $user_id -array user_array

######################################################################
#
# tasks
#
# a list showing description for all tasks in a sim
#
######################################################################

#---------------------------------------------------------------------
# tasks form
#---------------------------------------------------------------------

template::list::create \
    -name tasks \
    -multirow tasks \
    -no_data "No tasks in this Simulation" \
    -elements {
        pretty_name {
            link_url_col task_url
            label "Task"
            orderby upper(w.pretty_name)
        }
    }

#-------------------------------------------------------------
# tasks db_multirow
#-------------------------------------------------------------

db_multirow -extend { task_url } tasks tasks_sql "
    select wa.action_id,
           wa.pretty_name,
           wa.assigned_role,
           (select pretty_name 
              from workflow_roles
             where role_id = wa.assigned_role) as assigned_name,
           (select pretty_name 
              from workflow_roles
             where role_id = st.recipient) as recipient_name,
           wa.sort_order
      from workflow_actions wa,
           sim_tasks st
     where wa.workflow_id = :workflow_id
       and st.task_id = wa.action_id
     order by wa.sort_order
"  {
    set task_url [export_vars -base "[apm_package_url_from_id $package_id]siminst/task-edit" { action_id }]
}



