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

set elements [list]
lappend elements edit {
    hide_p {[ad_decode $display_mode edit 0 1]}
    sub_class narrow
    link_url_col edit_url
    display_template {
        <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border="0" alt="Edit">
    }
}
lappend elements initialize {
    label "Initialize"
    display_template {
        <if @tasks.initial_p@ true>
          <img src="/resources/acs-subsite/radiochecked.gif" height="13" width="13" border="0" alt="Initial action">
        </if>
        <else>
          <a href="@tasks.set_initial_url@"><img src="/resources/acs-subsite/radio.gif" height="13" width="13" border="0" alt="Set as initial action"></a>
        </else>
    }
    html { align center }
}
lappend elements name { 
    label "Name"
    display_col pretty_name
    link_url_col {[ad_decode $display_mode edit view_url ""]}
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
        [list label "<a href=\"[export_vars -base state-edit { state_id }]\"><img src=\"/resources/acs-subsite/Edit16.gif\" height=\"16\" width=\"16\" border=\"0\" alt=\"Edit\"></a> \${label_state_$state_id}" \
             html { align center } \
             display_template "
                 <switch @tasks.state_$state_id@>
                   <case value=\"assigned\">
                     <b>Assigned</b>
                   </case>
                   <case value=\"enabled\">
                     Enabled
                   </case>
                   <default>
                     &nbsp;
                   </default>
                </switch>
             "]

    lappend states $state_id
}

lappend elements add_state {
    label {
        <form action="state-edit" style="margin: 0px;">
        [export_vars -form { workflow_id}]
        <input type="submit" value="Add a state">
        </form>
    }
    display_template {&nbsp;}
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
    -actions $actions \
    -elements $elements

#-------------------------------------------------------------
# tasks db_multirow
#-------------------------------------------------------------
# TODO: fix this so it returns rows when it should  

set initial_action_id [workflow::get_element \
                           -workflow_id $workflow_id \
                           -element initial_action_id]

set extend [list]
lappend extend edit_url view_url delete_url initial_p set_initial_url

foreach state_id $states {
    lappend extend state_$state_id
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

ds_comment [array get enabled_in_state]


db_multirow -extend $extend tasks select_tasks "
    select wa.action_id,
           wa.pretty_name,
           (select pretty_name 
              from workflow_roles
             where role_id = wa.assigned_role) as assigned_name,
           (select pretty_name 
              from workflow_roles
             where role_id = st.recipient) as recipient_name,
           wa.sort_order,
           wa.always_enabled_p
      from workflow_actions wa,
           sim_tasks st
     where wa.workflow_id = :workflow_id
       and st.task_id = wa.action_id
     order by wa.sort_order
" {
    set edit_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-edit" { action_id }]
    set view_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-edit" { action_id }]
    set delete_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-delete" { action_id {return_url [ad_return_url]} }]
    set initial_p [string equal $initial_action_id $action_id]
    set set_initial_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/initial-action-set" { action_id {return_url [ad_return_url]} }]
    
    foreach state_id $states {
        ds_comment "enabled_in_state($action_id,$state_id)"
        if { [info exists enabled_in_state($action_id,$state_id)] } {
            if { [template::util::is_true $enabled_in_state($action_id,$state_id)] } {
                ds_comment "Assigned"
                set state_$state_id assigned
                ds_comment "set state_$state_id assigned -- $extend"
            } else {
                ds_comment "Enabled"
                set state_$state_id enabled
                ds_comment "set state_$state_id enabled -- $extend"
            }
        }
    }
}

