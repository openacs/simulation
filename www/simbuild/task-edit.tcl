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

######################################################################
#
# preparation
#
######################################################################

set package_key [ad_conn package_key]
set package_id [ad_conn package_id]

if { ![ad_form_new_p -key action_id] } {
    workflow::action::fsm::get -action_id $action_id -array task_array

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
set role_options [workflow::role::get_options -workflow_id $workflow_id]

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


ad_form -name task -export { workflow_id } -edit_buttons [list [list [ad_decode [ad_form_new_p -key action_id] 1 [_ acs-kernel.common_add] [_ acs-kernel.common_edit]] ok]] -form {
    {action_id:key}
    {pretty_name:text
        {label "Task Name"}
        {html {size 20}}
    }
    {assigned_role:text(select),optional
        {label "Assigned To"}
        {options $role_options}
    }
    {recipient_role:text(select),optional
        {label "Recipient"}
        {options $role_options}
    }
    {description:richtext,optional
        {label "Task Description"}
        {html {cols 60 rows 8}}
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
    {assigned_state_ids:text(checkbox),optional,multiple
        {label "Assigned<br>TODO: Find a better<br>way to show the<br>assigned/enabled states"}
        {options $enabled_options}
    }
    {enabled_state_ids:text(checkbox),optional,multiple
        {label "Enabled"}
        {options $enabled_options}
    }
}

ad_form -extend -name task -form {
    {new_state_id:integer(select),optional
        {label "New state"}
        {options $state_options}
    }
    {attachment_num:integer(text)
        {label "Number of attachments"}
        {help_text "These are placeholders that are matched to props by the case author during SimInst"}
        {html {size 2}}
    }
} -edit_request {
    set workflow_id $task_array(workflow_id)
    permission::require_write_permission -object_id $workflow_id
    set pretty_name $task_array(pretty_name)
    set description [template::util::richtext::create $task_array(description) $task_array(description_mime_type)]
    set new_state_id $task_array(new_state_id)
    
    db_1row select_recipient {
        select recipient as recipient_role_id, attachment_num
        from sim_tasks
        where task_id = :action_id
    }

    if { ![empty_string_p $recipient_role_id] } {
        set recipient_role [workflow::role::get_element -role_id $recipient_role_id -element short_name]
    } else {
        set recipient_role {}
    }

    set assigned_role $task_array(assigned_role)

    set assigned_state_ids $task_array(assigned_state_ids)
    set enabled_state_ids $task_array(enabled_state_ids)
} -new_request {
    permission::require_write_permission -object_id $workflow_id
} -on_submit {
    
    set description_mime_type [template::util::richtext::get_property format $description]
    set description [template::util::richtext::get_property contents $description]

    if { ![empty_string_p $recipient_role] } {
        set recipient_role_id [workflow::role::get_id -workflow_id $workflow_id -short_name $recipient_role]
    } else {
        set recipient_role_id [db_null]
    }
} -new_data {
    permission::require_write_permission -object_id $workflow_id
    # create the task

    db_transaction {
        set action_id [workflow::action::fsm::new \
                           -workflow_id $workflow_id \
                           -pretty_name $pretty_name \
                           -assigned_role $assigned_role \
                           -description $description \
                           -description_mime_type $description_mime_type \
                           -enabled_state_ids $enabled_state_ids \
                           -assigned_state_ids $assigned_state_ids \
                           -new_state_id $new_state_id]
        
        # TODO - put this stuff into simulation api and change previous call
        # and then add extra data for simulation
        # because workflow::action::fsm::new wants role.short_name instead of
        # role_id, we stay consistent for recipient_role

        array unset row
        set row(recipient_role) $recipient_role
        set row(attachment_num) $attachment_num

        simulation::action::edit \
            -action_id $action_id \
            -workflow_id $workflow_id \
            -array row
    }
} -edit_data {
    # We use task_array(workflow_id) here, which is gotten from the DB, and not
    # workflow_id, which is gotten from the form, because the workflow_id from the form 
    # could be spoofed
    permission::require_write_permission -object_id $task_array(workflow_id)

    # TODO IMPORTANT:
    # Set short_name right -- or leave blank and have the workflow API construct a short_name

    # TODO: enabled_states, assigned_states
    array unset row
    foreach col { pretty_name assigned_role recipient_role description description_mime_type enabled_state_ids assigned_state_ids attachment_num } {
        set row($col) [set $col]
    }
    set row(short_name) {}
    set row(new_state_id) $new_state_id

    simulation::action::edit \
        -action_id $action_id \
        -workflow_id $task_array(workflow_id) \
        -array row

} -after_submit {
    ad_returnredirect [export_vars -base "template-edit" { workflow_id }]
    ad_script_abort
}
