ad_page_contract {
    Add/edit task.

    @creation-date 2003-10-27
    @cvs-id $Id$
} {
    {workflow_id:integer ""}
    action_id:integer,optional
} -validate {
    workflow_id_or_task_id {
        if { ![exists_and_not_null workflow_id] &&
             ![exists_and_not_null action_id]} {
            ad_complain "Either task_id or workflow_id is required."
        }
    }
}

# TODO: form element to set trigger-instantly mode
# TODO: form element to set timeouts
# TODO: form element to "instantiate a child workflow and wait for it to complete"
# TODO: form element for mapping roles for child workflow

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
set role_options [concat [list [list "--None--" ""]] [workflow::role::get_options -workflow_id $workflow_id]]


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
    -export { workflow_id } \
    -edit_buttons [list \
                       [list \
                            [ad_decode [ad_form_new_p -key action_id] 1 [_ acs-kernel.common_add] [_ acs-kernel.common_edit]] \
                            ok]] \
    -form {
        {action_id:key}
        {pretty_name:text
            {label "Task Name"}
            {html {size 20}}
        }
        {pretty_past_tense:text,optional
            {label "Task name in log"}
            {html {size 20}}
            {help_text "What the task will appear like in the case log. Usually the past tense of the task name, e.g. 'Close' becomes 'Closed'."}
        }
        {task_type:text(radio)
            {label "Task is complete when"}
            {options { 
                { "Assignee sends message to recipient" message }
                { "Assignee uploads document" normal } 
                { "Child workflow is complete" workflow }
            }}
            {html {onChange "javascript:acs_FormRefresh('task');"}}
        }
        {assigned_role:text(select),optional
            {label "Assigned To"}
            {options $role_options}
        }
        {recipient_role:text(select),optional
            {label "Recipient"}
            {options $role_options}
        }
        {child_workflow_id:integer(select),optional
            {label "Child workflow"}
            {options {[simulation::template::get_options]}}
            {html {onChange "javascript:acs_FormRefresh('task');"}}
        }
    }

if { [string equal [element get_value task task_type] "workflow"] } {
    foreach role_id [workflow::get_roles -workflow_id [element get_value task child_workflow_id]] {
        set role__${role_id}__pretty_name [workflow::role::get_element -role_id $role_id -element pretty_name]
        ad_form -extend -name task -form \
            [list [list child__$role_id:text(select),optional \
                       [list label "\$role__${role_id}__pretty_name"] \
                       {options $role_options} \
                      ]]

    }
}

ad_form -extend -name task -form {
    {description:richtext,optional
        {label "Task Description"}
        {html {cols 60 rows 8}}
        {help_text "Suggested text; can be edited when template is instantiated."}
    }
    {attachment_num:integer(text)
        {label "Number of attachments"}
        {help_text "These are placeholders that are matched to props by the case author during SimInst"}
        {html {size 2}}
    }
}

set enabled_options [list]
set state_options [list]
lappend state_options [list "--Unchanged--" {}]
foreach state_id [workflow::fsm::get_states -workflow_id $workflow_id] {
    array unset state_array
    workflow::state::fsm::get -state_id $state_id -array state_array
    lappend enabled_options [list $state_array(pretty_name) $state_id]
    lappend state_options [list $state_array(pretty_name) $state_id]
}

ad_form -extend -name task -form {
    {new_state_id:integer(select),optional
        {label "Next state"}
        {options $state_options}
        {help_text "After this task is completed, change the template's state."}
    }
}

set focus "task.pretty_name"

ad_form -extend -name task -edit_request {
    set workflow_id $task_array(workflow_id)
    permission::require_write_permission -object_id $workflow_id
    set description [template::util::richtext::create $task_array(description) $task_array(description_mime_type)]

    foreach elm { 
        pretty_name pretty_past_tense new_state_id 
        assigned_role recipient_role
        attachment_num
    } {
        set $elm $task_array($elm)
    }

    # TODO: Check for child workflows, and set task_type to 'workflow'
    if { ![empty_string_p $task_array(recipient_role)] } {
        set task_type "message"
    } else {
        set task_type "normal"
    }

    switch $task_type {
        message {
            element set_properties task assigned_role -widget select
            element set_properties task recipient_role -widget select
            element set_properties task child_workflow_id -widget hidden
        }
        normal {
            element set_properties task assigned_role -widget select
            element set_properties task recipient_role -widget hidden
            element set_properties task child_workflow_id -widget hidden
        }
        workflow {
            element set_properties task assigned_role -widget hidden
            element set_properties task recipient_role -widget hidden
            element set_properties task child_workflow_id -widget select
        }
    }
} -new_request {
    permission::require_write_permission -object_id $workflow_id

    set attachment_num 0

    set task_type "message"
    element set_properties task child_workflow_id -widget hidden
} -on_refresh {
    switch $task_type {
        message {
            element set_properties task assigned_role -widget select
            element set_properties task recipient_role -widget select
            element set_properties task child_workflow_id -widget hidden
        }
        normal {
            element set_properties task assigned_role -widget select
            element set_properties task recipient_role -widget hidden
            element set_properties task child_workflow_id -widget hidden
        }
        workflow {
            element set_properties task assigned_role -widget hidden
            element set_properties task recipient_role -widget hidden
            element set_properties task child_workflow_id -widget select
        }
    }

    set focus {}
} -on_submit {
    
    set description_mime_type [template::util::richtext::get_property format $description]
    set description [template::util::richtext::get_property contents $description]

    switch $task_type {
        message {
            set child_workflow_id {}
        }
        normal {
            set recipient_role {}
            set child_workflow_id {}
        }
        workflow {
            set recipient_role {}
            error "Missing"
        }
    }

    # Default pretty_past_tense
    if { [empty_string_p $pretty_past_tense] } {
        set pretty_past_tense $pretty_name
    }

    foreach elm { 
        pretty_name pretty_past_tense assigned_role description description_mime_type
        new_state_id 
        recipient_role attachment_num
    } {
        set row($elm) [set $elm]
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

    ad_returnredirect [export_vars -base "template-edit" -anchor "tasks" { workflow_id }]
    ad_script_abort
}
