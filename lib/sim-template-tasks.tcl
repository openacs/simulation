# an includelet 

# the includelet can be a full edit

if { ![exists_and_not_null usage_mode] } {
    set usage_mode display
}

switch $usage_mode {
    display {}
    edit {
	set add_task_url [export_vars -base "task-edit" { workflow_id } ]
    }
    default { 
	error "This is an opportunity to inspect the code and find out how we got here, since it should be impossible" 
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



template::list::create \
    -name tasks \
    -multirow tasks \
    -no_data "No tasks in this Simulation Template" \
    -elements {
        edit {
            hide_p {[ad_decode $usage_mode edit 0 1]}
            sub_class narrow
            link_url_col edit_url
            display_template {
                <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border="0" alt="Edit">
            }
        }
        name { 
            label "Name"
	    link_url_col {[ad_decode $usage_mode edit view_url ""]}
        }
        assigned_name {
            label "Assigned to"
        }
        recipient_name {
            label "Recipient"
        }
        delete {
            sub_class narrow
            link_url_col delete_url
            hide_p {[ad_decode $usage_mode edit 0 1]}
            display_template {
                <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Edit">
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
           wa.pretty_name as name,
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
    [template::list::orderby_clause -orderby -name "tasks"]
" {
    set edit_url [export_vars -base "task-edit" { action_id }]
    set view_url [export_vars -base "task-edit" { action_id }]
    set delete_url [export_vars -base "task-delete" { action_id return_url }]
}
