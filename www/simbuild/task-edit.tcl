ad_page_contract {
    Add/edit task.

    @creation-date 2003-10-27
    @cvs-id $Id$
} {
    {workflow_id:integer ""}
    action_id:integer,optional
    parent_action_id:integer,optional
    return_url:optional
} -validate {
    workflow_id_or_task_id {
        if { ![exists_and_not_null workflow_id] &&
             ![exists_and_not_null action_id]} {
            ad_complain "Either task_id or workflow_id is required."
        }
    }
}

######################################################################
#
# preparation
#
######################################################################

set package_key [ad_conn package_key]
set package_id [ad_conn package_id]

if { ![ad_form_new_p -key action_id] } {
    simulation::action::get -action_id $action_id -array task_array

    set workflow_id $task_array(workflow_id)

    # Message tasks have a recipient; upload document tasks ("normal") have no recipient
    if { ![empty_string_p $task_array(recipient_roles)] } {
        set task_type "message"
    } else {
        set task_type "normal"
    }
    
    set trigger_type $task_array(trigger_type)
    set parent_action_id $task_array(parent_action_id)
}

workflow::get -workflow_id $workflow_id -array sim_template_array

if { ![ad_form_new_p -key action_id] } {
    set page_title "Edit Task $task_array(pretty_name)"
} else {

    set page_title "Add Task to $sim_template_array(pretty_name)"
}
set context [list [list "." "SimBuild"] [list [export_vars -base "template-edit" { workflow_id }] "$sim_template_array(pretty_name)"] $page_title]

#---------------------------------------------------------------------
# Get a list of relevant roles
#---------------------------------------------------------------------
set role_options [workflow::role::get_options -workflow_id $workflow_id]
set role_options_with_null [concat [list [list "--None--" ""]] $role_options]

#---------------------------------------------------------------------
# Logic to determine the current values of a few elements
#---------------------------------------------------------------------

if { ![empty_string_p [ns_queryget trigger_type]] } {
    set trigger_type [ns_queryget trigger_type]
} elseif { ![exists_and_not_null trigger_type] && [ad_form_new_p -key action_id] } {
    set trigger_type "user"
}
if { ![empty_string_p [ns_queryget task_type]] } {
    set task_type [ns_queryget task_type]
} elseif { ![exists_and_not_null task_type] && [ad_form_new_p -key action_id] } {
    set task_type "message"
}

######################################################################
#
# task
#
# a form showing fields for a task in a workflow
# includes add and edit modes and handles form submission
# display mode is only in list form via template-edit
#
######################################################################

#---------------------------------------------------------------------
# task form
#---------------------------------------------------------------------

ad_form \
    -name task \
    -export { workflow_id return_url } \
    -edit_buttons [list \
                       [list \
                            [ad_decode [ad_form_new_p -key action_id] 1 [_ acs-kernel.common_add] [_ acs-kernel.common_finish]] \
                            ok]] \
    -form {
        {action_id:key}
    }

if { [exists_and_not_null parent_action_id] } {
    simulation::action::get -action_id $parent_action_id -array parent_task_array
    ad_form -extend -name task -form {
        {parent_action_id:integer(select)
            {label "Parent task"}
            {mode display}
            {options {[workflow::action::get_options -workflow_id $workflow_id]}}
        }
    }
} else {
    ad_form -extend -name task -form {
        {parent_action_id:integer(hidden),optional {value {}}}
    }
}

ad_form -extend -name task -form {
    {pretty_name:text
        {label "Task Name"}
        {html {size 50}}
    }
    {pretty_past_tense:text,optional
        {label "Task name in log"}
        {html {size 50}}
        {help_text "What the task will appear like in the case log. Usually the past tense of the task name, e.g. 'Close' becomes 'Closed'."}
    }
    {trigger_type:text(radio)
        {label "Trigger Type"}
        {options { 
            { "User task" user } 
            { "Automatic timer" time } 
            { "Initial action" init } 
            { "Workflow" workflow } 
            { "Parallel" parallel } 
        }}
        {html {onChange "javascript:acs_FormRefresh('task');"}}
    }
}



if { [string equal $trigger_type "user"] } {
    ad_form -extend -name task -form {
        {task_type:text(radio)
            {label "Task is complete when"}
            {options { 
                { "Assignee sends message to recipient" message }
                { "Assignee adds document to portfolio" normal } 
            }}
            {html {onChange "javascript:acs_FormRefresh('task');"}}
        }
        {assigned_role:text(select),optional
            {label "Assignee"}
            {options $role_options_with_null}
        }
    }
} else {
    ad_form -extend -name task -form { 
        {task_type:text(hidden)} 
        {assigned_role:text(hidden),optional}
    }
}

if { [string equal $trigger_type "user"] && [string equal $task_type "message"] } {
    ad_form -extend -name task -form {
        {recipient_roles:text(checkbox),optional,multiple
            {label "Recipients"}
            {options $role_options}
        }
    }
} else {
    ad_form -extend -name task -form { 
        {recipient_roles:text(hidden),optional}
    }
}


switch $trigger_type {
    user - message - workflow - parallel - dynamic {
        ad_form -extend -name task -form { 
            {timeout_seconds:integer(text),optional
                {label "Timeout"}
                {after_html "seconds"}
            }
        }
    }
    time {
        ad_form -extend -name task -form { 
            {timeout_seconds:integer(text)
                {label "Timeout"}
                {after_html "seconds"}
            }
        }
    }
    default {
        ad_form -extend -name task -form { 
            {timeout_seconds:integer(hidden),optional}
        }
    }
}

switch $trigger_type {
    init {
    }
    default {
        ad_form -extend -name task -form {
            {description:richtext,optional
                {label "Task Description"}
                {html {cols 60 rows 8}}
                {help_text "Suggested text; can be edited when template is instantiated."}
            }
        }
    }
}

if { [string equal $trigger_type "user"] } {
    ad_form -extend -name task -form {
        {attachment_num:integer(text)
            {label "Number of attachments"}
            {help_text "These are placeholders that are matched to props by the case author during SimInst"}
            {html {size 2}}
        }
    }
} else {
    ad_form -extend -name task -form {
        {attachment_num:integer(hidden) {value 0}}
    }
}

set enabled_options [list]
set state_options [list]
lappend state_options [list "--Unchanged--" {}]
foreach state_id [workflow::fsm::get_states -workflow_id $workflow_id -parent_action_id $parent_action_id] {
    array unset state_array
    workflow::state::fsm::get -state_id $state_id -array state_array
    lappend enabled_options [list $state_array(pretty_name) $state_id]
    lappend state_options [list $state_array(pretty_name) $state_id]
}

if { [exists_and_equal parent_task_array(trigger_type) "parallel"] || [exists_and_equal parent_task_array(trigger_type) "dynamic"] } {
    ad_form -extend -name task -form {
        {new_state_id:integer(hidden),optional}
    }
} else {
    ad_form -extend -name task -form {
        {new_state_id:integer(select),optional
            {label "Next state"}
            {options $state_options}
            {help_text "After this task is completed, change the template's state."}
        }
    }
}

set focus "task.pretty_name"

ad_form -extend -name task -edit_request {
    set workflow_id $task_array(workflow_id)
    permission::require_write_permission -object_id $workflow_id
    set description [template::util::richtext::create $task_array(description) $task_array(description_mime_type)]

    foreach elm { 
        pretty_name pretty_past_tense new_state_id 
        assigned_role recipient_roles
        attachment_num trigger_type timeout_seconds parent_action_id
    } {
        set $elm $task_array($elm)
    }

} -new_request {
    permission::require_write_permission -object_id $workflow_id

    set attachment_num 0

    set trigger_type "user"
    set task_type "message"
} -on_refresh {    
    set focus {}
} -on_submit {

    # Check that pretty_name is unique
    set unique_p [workflow::action::pretty_name_unique_p \
                      -workflow_id $workflow_id \
                      -action_id $action_id \
                      -pretty_name $pretty_name]
    
    if { !$unique_p } {
        form set_error task pretty_name "This name is already used by another task"
        break
    }

    if { [info exists description] } {
        set description_mime_type [template::util::richtext::get_property format $description]
        set description [template::util::richtext::get_property contents $description]
    }

    switch $task_type {
        message {
        }
        normal {
            set recipient_roles {}
        }
    }

    # Default pretty_past_tense
    if { [empty_string_p $pretty_past_tense] } {
        set pretty_past_tense $pretty_name
    }

    foreach elm { 
        pretty_name pretty_past_tense assigned_role description description_mime_type
        new_state_id timeout_seconds
        recipient_roles attachment_num trigger_type parent_action_id
    } {
        if { [info exists $elm] } {
            set row($elm) [set $elm]
        }
    }
    set row(short_name) {}

} -new_data {
    permission::require_write_permission -object_id $workflow_id
    set operation "insert"

} -edit_data {
    # We use task_array(workflow_id) here, which is gotten from the DB, and not
    # workflow_id, which is gotten from the form, because the workflow_id from the form 
    # could be spoofed
    set workflow_id $task_array(workflow_id)

    permission::require_write_permission -object_id $workflow_id

    set operation "update"

} -after_submit {
    
    set action_id [simulation::action::edit \
                       -operation $operation \
                       -workflow_id $workflow_id \
                       -action_id $action_id \
                       -array row]

    if { ![exists_and_not_null return_url] } {
        set return_url [export_vars -base "template-edit" -anchor "tasks" { workflow_id }] 
    } 
    ad_returnredirect $return_url
    ad_script_abort
}
