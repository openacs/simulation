ad_page_contract {
    Task details, specifically subtasks.

    @creation-date 2004-01-23
    @cvs-id $Id$
} {
    action_id:integer
    return_url:optional
}

######################################################################
#
# preparation
#
######################################################################

set package_key [ad_conn package_key]
set package_id [ad_conn package_id]

simulation::action::get -action_id $action_id -array task_array

set workflow_id $task_array(workflow_id)

workflow::get -workflow_id $workflow_id -array sim_template_array

set page_title "Task $task_array(pretty_name)"

set template_url [export_vars -base "template-edit" { workflow_id }]

set context [list [list "." "SimBuild"] [list $template_url "$sim_template_array(pretty_name)"] $page_title]

if { ![empty_string_p $task_array(parent_action_id)] } {
    simulation::action::get -action_id $task_array(parent_action_id) -array parent_task_array
    set parent_action_url [export_vars -base task-details { { action_id $task_array(parent_action_id) } }]
}

ad_form \
    -name task \
    -export { workflow_id return_url } \
    -mode display \
    -display_buttons { } \
    -form {
        {pretty_name:text
            {label "Task Name"}
            {html {size 50}}
        }
        {trigger_type:text(select)
            {label "Trigger Type"}
            {options { 
                { "User task" user } 
                { "Automatic timer" time } 
                { "Initial action" init } 
                { "Workflow" workflow } 
                { "Parallel" parallel } 
            }}
        }
    } -on_request {
        set pretty_name $task_array(pretty_name)
        set trigger_type $task_array(trigger_type)
    }

