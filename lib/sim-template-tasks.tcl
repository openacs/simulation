simulation::include_contract {
    A list of all tasks associated with the Simulation Template

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    workflow_id {}
    display_mode {
        allowed_values {edit display}
        default_value display
    }
}

set package_id [ad_conn package_id]

switch $display_mode {
    display {}

    edit {
	set add_task_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-edit" { workflow_id } ]
    }
}

##############################################################
#
# tasks
#
# A list of all tasks associated with the Simulation Template
#
##############################################################

#-------------------------------------------------------------
# tasks list 
#-------------------------------------------------------------
# TODO: missing: discription, type
# how is type going to work?  open question pending prototyping

if { $display_mode == "edit"} {
    set actions [list "Add a Task" [export_vars -base task-edit {workflow_id} ]]
} else {
    set actions ""
}

template::list::create \
    -name tasks \
    -multirow tasks \
    -no_data "No tasks in this Simulation Template" \
    -actions $actions \
    -elements {
        edit {
            hide_p {[ad_decode $display_mode edit 0 1]}
            sub_class narrow
            link_url_col edit_url
            display_template {
                <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border="0" alt="Edit">
            }
        }
        name { 
            label "Name"
            display_col pretty_name
	    link_url_col {[ad_decode $display_mode edit view_url ""]}
        }
        assigned_name {
            label "Assigned to"
        }
        recipient_name {
            label "Recipient"
        }
        delete {
            sub_class narrow
            hide_p {[ad_decode $display_mode edit 0 1]}
            display_template {
                <a href="@tasks.delete_url@" onclick="return confirm('Are you sure you want to delete task @tasks.pretty_name@?');">
                  <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Edit">
                </a>
            }
        }
    }

#-------------------------------------------------------------
# tasks db_multirow
#-------------------------------------------------------------
# TODO: fix this so it returns rows when it should        
set return_url "[ad_conn url]?[ad_conn query]"
db_multirow -extend { edit_url view_url delete_url } tasks select_tasks "
    select wa.action_id,
           wa.pretty_name,
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
     order by lower(pretty_name)
" {
    set edit_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-edit" { action_id }]
    set view_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-edit" { action_id }]
    set delete_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-delete" { action_id return_url }]
}

