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

ad_form -name task -edit_buttons [
				  list [list [ad_decode [ad_form_new_p -key action_id] 1 [_ acs-kernel.common_add] [_ acs-kernel.common_edit]] ok]
    ] -form {
    {action_id:key}
    {workflow_id:integer(hidden)
        {value $workflow_id}
    }
    {name:text
        {label "Task Name"}
        {html {size 20}}
    }
    {assigned_role:text(select)
        {label "Assigned To"}
        {options $role_options}
    }
    {recipient_role:text(select)
        {label "Recipient"}
        {options $role_options}
    }
    {description:richtext,optional
        {label "Task Description"}
        {html {cols 60 rows 8}}
    }
} -edit_request {
    set workflow_id $task_array(workflow_id)
    permission::require_write_permission -object_id $workflow_id
    set name $task_array(pretty_name)
    set description [template::util::richtext::create $task_array(description) $task_array(description_mime_type)]
    set recipient_role_id [db_string select_recipient {
        select recipient
        from sim_tasks
        where task_id = :action_id
    }]
    set recipient_role [workflow::role::get_element -role_id $recipient_role_id -element short_name]

   set assigned_role $task_array(assigned_role)
} -new_request {
    permission::require_write_permission -object_id $workflow_id
} -on_submit {
    
    set description_content [template::util::richtext::get_property contents $description]
    set description_mime_type [template::util::richtext::get_property format $description]

} -new_data {
    permission::require_write_permission -object_id $workflow_id
    # create the task

    set action_id [workflow::action::fsm::new \
		       -workflow_id $workflow_id \
		       -short_name $name \
		       -pretty_name $name \
		       -assigned_role $assigned_role \
		       -description $description_content \
		       -description_mime_type $description_mime_type]

    # TODO - put this stuff into simulation api and change previous call
    # and then add extra data for simulation
    # because workflow::action::fsm::new wants role.short_name instead of
    # role_id, we stay consistent for recipient_role
    set recipient_role_id [workflow::role::get_id -workflow_id $workflow_id -short_name $recipient_role]
    db_dml set_role_recipient {
        insert into sim_tasks
        values (:action_id, :recipient_role_id)
    }
} -edit_data {
    # We use task_array(workflow_id) here, which is gotten from the DB, and not
    # workflow_id, which is gotten from the form, because the workflow_id from the form 
    # could be spoofed
    permission::require_write_permission -object_id $task_array(workflow_id)
    simulation::action::edit \
        -action_id $action_id \
        -short_name $name \
        -pretty_name $name \
        -assigned_role $assigned_role \
        -recipient_role $recipient_role \
	-description $description_content \
	-description_mime_type $description_mime_type

} -after_submit {
    ad_returnredirect [export_vars -base "template-edit" { workflow_id }]
    ad_script_abort
}
