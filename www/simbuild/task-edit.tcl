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

# TODO: add functionality from mockups, including:
# form element to set trigger-instantly mode
# form element to "instantiate a child workflow and wait for it to complete"
# form element for mapping roles for child workflow
# form element to set timeouts
# form element to add side effects
# form element for bulk vs individual group assignment:
#   when a group is mapped to a role in a sub-workflow, this can mean
#     1) make one case, and assign the group as one party to the role,
#     2) make one case per member of the group, and assign each member
#        individually
#   In case 2, figure out what to do if some roles are groups and others
#   aren't.

# TODO: fancy attachment placeholders (not priority 1)
#   replace simple count with Add placeholder for [attachment type]
#   and embed links within the description

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
    set description [template::util::richtext::create $task_array(description) $task_array(description_mime_type)]

    foreach elm { 
        pretty_name new_state_id 
        assigned_role recipient_role
        assigned_state_ids enabled_state_ids
        attachment_num
    } {
        set $elm $task_array($elm)
    }
} -new_request {
    permission::require_write_permission -object_id $workflow_id

    #TODO: is this the right way to set defaults in ad_form?
    set attachment_num 0
} -on_submit {
    
    set description_mime_type [template::util::richtext::get_property format $description]
    set description [template::util::richtext::get_property contents $description]

    foreach elm { 
        pretty_name assigned_role description description_mime_type
        enabled_state_ids assigned_state_ids new_state_id 
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
