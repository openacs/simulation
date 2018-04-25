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
    parent_action_id {
        default_value {}
    }
}

set package_id [ad_conn package_id]

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

if { $display_mode == "edit"} {
    set list_actions [list "Add a Task" [export_vars -base task-edit { workflow_id parent_action_id {return_url "[ad_return_url]" } }] {}]
} else {
    set list_actions {}
}

set show_states_p 1
if { ![empty_string_p $parent_action_id] } {
    simulation::action::get -action_id $parent_action_id -array parent_task_array
    if { [lsearch -exact { parallel dynamic } $parent_task_array(trigger_type)] != -1 } { 
        set show_states_p 0
    }
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
lappend elements down {
    sub_class narrow
    display_template {
        <if @tasks.down_url@ not nil>
          <a href="@tasks.down_url@" class="button" style="padding-top: 6px; padding-bottom: -2px; padding-left: 1px; padding-right: 1px;"><img src="/resources/acs-subsite/arrow-down.gif" border="0"></a>
        </if>
    }
}
lappend elements up {
    sub_class narrow
    display_template {
        <if @tasks.up_url@ not nil>
        <a href="@tasks.up_url@" class="button" style="padding-top: 6px; padding-bottom: -2px; padding-left: 1px; padding-right: 1px;"><img src="/resources/acs-subsite/arrow-up.gif" border="0"></a>
        </if>
    }
}

lappend elements name { 
    label "<br />Name"
    display_col pretty_name
    link_url_col {[ad_decode $display_mode edit view_url ""]}
}

lappend elements trigger_type { 
    label "<br />Type"
    display_eval {[string totitle $trigger_type] [ad_decode $num_subactions "" "" "($num_subactions subtasks)"]}
    link_url_col add_child_action_url
    link_html { title "Edit subtasks" }
}

lappend elements assigned_name { 
    label "<br />Assignee"
    link_url_col assigned_role_edit_url
}

lappend elements copy {
    hide_p {[ad_decode $display_mode edit 0 1]}
    sub_class narrow
    link_url_col copy_url
    display_template {
        <img src="/resources/acs-subsite/Copy16.gif" height="16" width="16" border="0" alt="Copy">
    }
}

lappend elements delete {
    sub_class narrow
    hide_p {[ad_decode $display_mode edit 0 1]}
    display_template {
        <a href="@tasks.delete_url@" onclick="return confirm('Are you sure you want to delete task @tasks.pretty_name@?');">
          <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Delete">
        </a>
    }
}

if { !$show_states_p } {
    set states {}
} else {
    lappend elements state_spacer { 
        label "<br />Enabled in States:"
        sub_class narrow
        display_template " "
        html { style "border-left: 2px dotted #A0BDEB;" }
    }

    set states {}

    db_foreach select_states {
        select s.state_id,
               s.pretty_name,
               s.short_name
        from   workflow_fsm_states s
        where  workflow_id = :workflow_id
        and    ((:parent_action_id is null and s.parent_action_id is null) or (s.parent_action_id = :parent_action_id))
        order  by s.sort_order
    } {
        set "label_state_$state_id" "<span style=\"background-color: lightblue\">$pretty_name</span>"
        lappend elements state_$state_id \
            [list label "<a href=\"[export_vars -base state-edit { state_id }]\"><img src=\"/resources/acs-subsite/Edit16.gif\" height=\"16\" width=\"16\" border=\"0\" alt=\"Edit\"></a><a href=\"[export_vars -base state-delete { state_id }]\"><img src=\"/resources/acs-subsite/Delete16.gif\" height=\"16\" width=\"16\" border=\"0\" alt=\"Delete\"></a><br/>\${label_state_$state_id}" \
                 html { align center } \
                 display_template "
                     <if @tasks.state_$state_id@ not nil>
                       <a href=\"@tasks.state_${state_id}_url@\" class=\"button\" style=\"padding-top: 4px; padding-bottom: 0px;\"><img src=\"/resources/acs-subsite/checkboxchecked.gif\" border=\"0\" height=\"13\" width=\"13\"></a>
                     </if>
                     <else>
                       <a href=\"@tasks.state_${state_id}_url@\" class=\"button\" style=\"padding-top: 4px; padding-bottom: 0px;\"><img src=\"/resources/acs-subsite/checkbox.gif\" border=\"0\" height=\"13\" width=\"13\"></a>
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
}

template::list::create \
    -name tasks \
    -multirow tasks \
    -no_data "No [ad_decode $parent_action_id "" "tasks in this Simulation Template" "subtasks for this task"]" \
    -sub_class narrow \
    -actions $list_actions \
    -elements $elements

#-------------------------------------------------------------
# tasks db_multirow
#-------------------------------------------------------------

set extend [list]
lappend extend edit_url view_url delete_url assigned_role_edit_url up_url down_url add_child_action_url copy_url

foreach state_id $states {
    lappend extend state_$state_id
    lappend extend move_to_$state_id
    lappend extend state_${state_id}_url
}

array set enabled_in_state {}

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
set counter 0

db_multirow -extend $extend tasks select_tasks "
    select wa.action_id,
           wa.pretty_name,
           wa.assigned_role,
           (select count(*)
            from sim_task_recipients str
            where str.task_id = wa.action_id
           ) as recipient_count,
           (select pretty_name 
              from workflow_roles
             where role_id = wa.assigned_role) as assigned_name,
           wa.sort_order,
           wa.always_enabled_p,
           wfa.new_state,
           (select pretty_name
            from   workflow_fsm_states
            where  state_id = wfa.new_state) as new_state_pretty,
           wa.trigger_type,
           (select count(*) from workflow_actions where parent_action_id = wa.action_id) as num_subactions
      from workflow_actions wa left outer join
           workflow_fsm_actions wfa on (wfa.action_id = wa.action_id)
     where wa.workflow_id = :workflow_id
     and   wa.parent_action_id [ad_decode $parent_action_id "" "is null" "= :parent_action_id"]
     order by wa.sort_order
" {
    incr counter
    set edit_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-edit" -anchor tasks { action_id {return_url "[ad_return_url]"} }]
    set view_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-edit" -anchor tasks { action_id {return_url "[ad_return_url]"}}]
    set delete_url \
        [export_vars -base "[apm_package_url_from_id $package_id]simbuild/task-delete" { action_id workflow_id {return_url "[ad_return_url]"} }]
    set copy_url [export_vars -base task-copy { action_id workflow_id {return_url "[ad_return_url]"} }]

    set assigned_role_edit_url \
        [export_vars -base "[apm_package_url_from_id $package_id]simbuild/role-edit" { { role_id $assigned_role } }]
    
    foreach state_id $states {

        if { [info exists enabled_in_state($action_id,$state_id)] } {
            set __enabled__${action_id}__${state_id} "t"
            if { [template::util::is_true $enabled_in_state($action_id,$state_id)] } {
                set state_$state_id assigned
            } else {
                set state_$state_id enabled
            }
            set state_${state_id}_url [export_vars -base task-enabled-in-state-update { action_id state_id { enabled_p f } { return_url {[ad_return_url]} } }]
        } else {
            set state_${state_id}_url [export_vars -base task-enabled-in-state-update { action_id state_id { return_url {[ad_return_url]} } }]

        }
        if { $new_state == $state_id } {
            set move_to_$state_id 1
        }
    }

    if { $counter > 1 } {
        set up_url [export_vars -base "[ad_conn package_url]simbuild/template-object-reorder" { { type action } action_id { direction up } { return_url "[ad_return_url]" } { parent_action_id $parent_action_id } }]
    }
    set down_url [export_vars -base "[ad_conn package_url]simbuild/template-object-reorder" { { type action } action_id { direction down } { return_url "[ad_return_url]" } { parent_action_id $parent_action_id } }]

    switch $trigger_type {
        workflow - parallel - dynamic {
            set add_child_action_url [export_vars -base task-details { action_id }]
        }
        default {
            set num_subactions {}
        }
    }

    lappend actions $action_id

    if { [empty_string_p $new_state_pretty] } {
        set new_state_pretty "unchanged"
    }
}

# Get rid of the last down_url
set tasks:${counter}(down_url) {}
