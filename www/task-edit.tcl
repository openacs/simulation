ad_page_contract {
    Add/edit task.

    @creation-date 2003-10-27
    @cvs-id $Id$
} {
    workflow_id:optional
    action_id:optional
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

# this part may be superfluous since we do the same thing in edit mode
# TODO - if so, cut it
if { ![exists_and_not_null workflow_id] } {
    set workflow_id [db_string get_workflow_from_role "select workflow_id
                                                         from workflow_actions
                                                        where action_id = :action_id"
                    ]
}

workflow::get -workflow_id $workflow_id -array workflow

#---------------------------------------------------------------------
# Get a list of relevant roles
#---------------------------------------------------------------------
# TODO: make sure this query (and other queries to cr) get only the live
# record from cr_revisions
# deliberately not checking to see if character is already cast in sim
# because no reason not to have same character in multiple tasks (?)

set role_options [db_list_of_lists role_option_list "
    select wr.pretty_name,
           wr.short_name
      from workflow_roles wr
     where wr.workflow_id = :workflow_id
"]

######################################################################
#
# task
#
# a form showing fields for a task in a workflow
# includes add and edit modes and handles form submission
# display mode is only in list form via sim-template-edit
#
######################################################################

#---------------------------------------------------------------------
# task form
#---------------------------------------------------------------------

ad_form -name task -cancel_url sim-template-list -form {
    {action_id:key}
    {workflow_id:integer(hidden),optional}
    {name:text
        {label "Task"}
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
} -edit_request {

    # Retrieve the task and populate the form
    workflow::action::fsm::get -action_id $action_id -array task_array
    set workflow_id $task_array(workflow_id)
    set name $task_array(pretty_name)
    workflow::get -workflow_id $workflow_id -array sim_template_array    
    set page_title "Edit Task $name"
    set context [list [list "sim-template-list" "Sim Templates"] [list "sim-template-edit?workflow_id=$workflow_id" "$sim_template_array(pretty_name)"] $page_title]    

} -new_request {

    # Set up the page for a new task
    workflow::get -workflow_id $workflow_id -array sim_template_array
    set page_title "Add Task to $sim_template_array(pretty_name)"
    set context [list [list "sim-template-list" "Sim Templates"] [list "sim-template-edit?workflow_id=$workflow_id" "$sim_template_array(pretty_name)"] $page_title]

} -new_data {

    # create the task
    set action_id [workflow::action::fsm::new \
                     -workflow_id $workflow_id \
                     -short_name $name \
                     -pretty_name $name \
                     -assigned_role $assigned_role]
    # and then add extra data for simulation
    # because workflow::action::fsm::new wants role.short_name instead of
    # role_id, we stay consistent for recipient_role
    set recipient_role_id [workflow::role::get_id -workflow_id $workflow_id  -short_name $recipient_role]
    db_dml set_role_recipient {
        insert into sim_tasks
        values (:action_id, :recipient_role_id)
    }
} -edit_data {

    simulation::action::edit \
        -action_id $action_id \
        -short_name $name \
        -pretty_name $name \
        -assigned_role $assigned_role \
        -recipient_role $recipient_role 

} -after_submit {
    ad_returnredirect [export_vars -base "sim-template-edit" { workflow_id }]
    ad_script_abort
}

