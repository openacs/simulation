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
	set add_task_url [export_vars -base "[apm_package_url_from_id $package_id]jsimbuild/task-edit" { workflow_id } ]
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
    set actions [list "Add a State" [export_vars -base state-edit { workflow_id}] {}]
    lappend actions "Add a Task" [export_vars -base task-edit {workflow_id} ] {}
} else {
    set actions ""
}

set elements [list]
lappend elements edit {
    hide_p {[ad_decode $display_mode edit 0 1]}
    sub_class narrow
    link_url_col edit_url
    display_template {
        <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border="0" alt="Edit">
    }
}
lappend elements name { 
    label "Name"
    display_col pretty_name
    link_url_col {[ad_decode $display_mode edit view_url ""]}
}

lappend elements assigned_name { 
    label "Assignee"
    link_url_col assigned_role_edit_url
}

lappend elements recipient_name { 
    label "Recipient"
    link_url_col recipient_role_edit_url
}

lappend elements state_spacer { 
    label "|&nbsp;&nbsp;&nbsp;States:"
    sub_class narrow
    display_template " "
}

set states [list]

db_foreach select_states {
    select s.state_id,
           s.pretty_name,
           s.short_name
    from   workflow_fsm_states s
    where  workflow_id = :workflow_id
    order  by s.sort_order
} {
    set "label_state_$state_id" $pretty_name
    lappend elements state_$state_id \
        [list label "\${label_state_$state_id}<br/> <a href=\"[export_vars -base state-edit { state_id }]\"><img src=\"/resources/acs-subsite/Edit16.gif\" height=\"16\" width=\"16\" border=\"0\" alt=\"Edit\"></a><a href=\"[export_vars -base state-delete { state_id }]\"><img src=\"/resources/acs-subsite/Delete16.gif\" height=\"16\" width=\"16\" border=\"0\" alt=\"Delete\"></a>" \
             html { align center } \
             display_template "
<input type=checkbox TODO=\"make this real\"></input>
             "]

    lappend states $state_id
} if_no_rows {
    lappend elements state_spacer3 { 
        label "<span class=\"form-required-mark\">None.  Template will not work until you add states.</span>"
        sub_class narrow
        display_template " "
    }
}

lappend elements delete {
    sub_class narrow
    hide_p {[ad_decode $display_mode edit 0 1]}
    display_template {
        <a href="@tasks.delete_url@" onclick="return confirm('Are you sure you want to delete task @tasks.pretty_name@?');">
          <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Edit">
        </a>
    }
}

template::list::create \
    -name tasks \
    -multirow tasks \
    -no_data "No tasks in this Simulation Template" \
    -sub_class narrow \
    -actions $actions \
    -elements $elements

#-------------------------------------------------------------
# tasks db_multirow
#-------------------------------------------------------------

set initial_action_id [workflow::get_element \
                           -workflow_id $workflow_id \
                           -element initial_action_id]

set extend [list]
lappend extend edit_url view_url delete_url initial_p set_initial_url assigned_role_edit_url recipient_role_edit_url

foreach state_id $states {
    lappend extend state_$state_id
    lappend extend move_to_$state_id
}

array set enabled_in_state [list]

# Ordering by assigned_p, so we get assigned states ('t') last
db_foreach select_enabled_in_states {
    select aeis.action_id,
           aeis.state_id,
           aeis.assigned_p
    from   workflow_actions a,
           workflow_fsm_action_en_in_st aeis
    where  a.workflow_id = :workflow_id
    and    aeis.action_id = a.action_id
    order  by aeis.assigned_p
} {
    set enabled_in_state($action_id,$state_id) $assigned_p
}

db_multirow -extend $extend tasks select_tasks "
    select wa.action_id,
           wa.pretty_name,
           wa.assigned_role,
           st.recipient as recipient_role,
           (select pretty_name 
              from workflow_roles
             where role_id = wa.assigned_role) as assigned_name,
           (select pretty_name 
              from workflow_roles
             where role_id = st.recipient) as recipient_name,
           wa.sort_order,
           wa.always_enabled_p,
           wfa.new_state
      from workflow_actions wa left outer join
           sim_tasks st on (st.task_id = wa.action_id),
           workflow_fsm_actions wfa 
     where wa.workflow_id = :workflow_id
       and wfa.action_id = wa.action_id
       and not exists (select 1
                         from workflow_initial_action ia
                        where ia.workflow_id = wa.workflow_id
                          and ia.action_id = wa.action_id)
     order by wa.sort_order
" {
    set edit_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-edit" { action_id }]
    set view_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-edit" { action_id }]
    set delete_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-delete" { action_id {return_url [ad_return_url]} }]

    set assigned_role_edit_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/role-edit" { { role_id $assigned_role } }]
    set recipient_role_edit_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/role-edit" { { role_id $recipient_role } }]

    set initial_p [string equal $initial_action_id $action_id]
    set set_initial_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/initial-action-set" { action_id {return_url [ad_return_url]} }]
    
    foreach state_id $states {
        if { [info exists enabled_in_state($action_id,$state_id)] } {
            if { [template::util::is_true $enabled_in_state($action_id,$state_id)] } {
                set state_$state_id assigned
            } else {
                set state_$state_id enabled
            }
        }
        if { $new_state == $state_id } {
            set move_to_$state_id 1
        }
    }
}


