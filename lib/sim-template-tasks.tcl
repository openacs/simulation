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
    set list_actions [list "Add a Task" [export_vars -base task-edit {workflow_id} ] {}]
} else {
    set list_actions [list]
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
    label "<br />Name"
    display_col pretty_name
    link_url_col {[ad_decode $display_mode edit view_url ""]}
}

lappend elements assigned_name { 
    label "<br />Assignee"
    link_url_col assigned_role_edit_url
}

lappend elements recipient_name { 
    label "<br />Recipient"
    link_url_col recipient_role_edit_url
}

lappend elements task_type { 
    label "<br />Type"
    display_template {
        <if @tasks.child_workflow_pretty@ not nil>
          <a href="@tasks.child_workflow_url@">@tasks.child_workflow_pretty@</a>
        </if>
        <else>
          <if @tasks.recipient_name@ not nil>Message</if>
          <else>Document</else>
        </else>
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

lappend elements state_spacer { 
    label "<br />Enabled in States:"
    sub_class narrow
    display_template " "
    html { style "border-left: 2px dotted #A0BDEB;" }
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
    set "label_state_$state_id" "<span style=\"background-color: lightblue\">$pretty_name</span>"
    lappend elements state_$state_id \
        [list label "<a href=\"[export_vars -base state-edit { state_id }]\"><img src=\"/resources/acs-subsite/Edit16.gif\" height=\"16\" width=\"16\" border=\"0\" alt=\"Edit\"></a><a href=\"[export_vars -base state-delete { state_id }]\"><img src=\"/resources/acs-subsite/Delete16.gif\" height=\"16\" width=\"16\" border=\"0\" alt=\"Delete\"></a><br/>\${label_state_$state_id}" \
             html { align center } \
             display_template "
                 <if @tasks.state_$state_id@ not nil>
                   <a href=\"@tasks.state_${state_id}_url@\" class=\"button\" style=\"padding-top: 4px; padding-bottom: 0px;\"><img src=\"/resources/acs-subsite/checkboxchecked.gif\" border=\"0\" height=\"13\" width=\"13\" style=\"background-color: white;\"></a>
                 </if>
                 <else>
                   <a href=\"@tasks.state_${state_id}_url@\" class=\"button\" style=\"padding-top: 4px; padding-bottom: 0px;\"><img src=\"/resources/acs-subsite/checkbox.gif\" border=\"0\" height=\"13\" width=\"13\" style=\"background-color: white;\"></a>
                 </else>
             "]

    lappend states $state_id
} if_no_rows {
    lappend elements state_spacer3 { 
        label "<br /><span class=\"form-required-mark\">None.  Template will not work until you add states.</span>"
        sub_class narrow
        display_template " "
    }
}

lappend elements new_state_pretty { 
    label "<br />Next state"
    html { style "border-left: 2px dotted #A0BDEB;" }
}

template::list::create \
    -name tasks \
    -multirow tasks \
    -no_data "No tasks in this Simulation Template" \
    -sub_class narrow \
    -actions $list_actions \
    -elements $elements

#-------------------------------------------------------------
# tasks db_multirow
#-------------------------------------------------------------

set extend [list]
lappend extend edit_url view_url delete_url assigned_role_edit_url recipient_role_edit_url child_workflow_url

foreach state_id $states {
    lappend extend state_$state_id
    lappend extend move_to_$state_id
    lappend extend state_${state_id}_url
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

set actions [list]

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
           wfa.new_state,
           (select pretty_name
            from   workflow_fsm_states
            where  state_id = wfa.new_state) as new_state_pretty,
           wa.child_workflow_id,
           (select pretty_name
            from   workflows
            where  workflow_id = wa.child_workflow_id) as child_workflow_pretty
      from workflow_actions wa left outer join
           sim_tasks st on (st.task_id = wa.action_id) left outer join
           workflow_fsm_actions wfa on (wfa.action_id = wa.action_id)
     where wa.workflow_id = :workflow_id
       and not exists (select 1
                         from workflow_initial_action ia
                        where ia.workflow_id = wa.workflow_id
                          and ia.action_id = wa.action_id)
     order by wa.sort_order
" {
    set edit_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-edit" { action_id }]
    set view_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-edit" { action_id }]
    set delete_url \
        [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-delete" { action_id {return_url [ad_return_url]} }]

    set assigned_role_edit_url \
        [export_vars -base "[apm_package_url_from_id $package_id]simbuild/role-edit" { { role_id $assigned_role } }]
    set recipient_role_edit_url \
        [export_vars -base "[apm_package_url_from_id $package_id]simbuild/role-edit" { { role_id $recipient_role } }]
    
    set child_workflow_url \
        [export_vars -base "[apm_package_url_from_id $package_id]simbuild/template-edit" { { workflow_id $child_workflow_id } }]

    foreach state_id $states {

        if { [info exists enabled_in_state($action_id,$state_id)] } {
            set __enabled__${action_id}__${state_id} "t"
            if { [template::util::is_true $enabled_in_state($action_id,$state_id)] } {
                set state_$state_id assigned
            } else {
                set state_$state_id enabled
            }
            set state_${state_id}_url [export_vars -base task-enabled-in-state-update { action_id state_id { enabled_p f } { return_url {[ad_return_url]\#tasks} } }]
        } else {
            set state_${state_id}_url [export_vars -base task-enabled-in-state-update { action_id state_id { return_url {[ad_return_url]\#tasks} } }]

        }
        if { $new_state == $state_id } {
            set move_to_$state_id 1
        }
    }

    lappend actions $action_id
}


