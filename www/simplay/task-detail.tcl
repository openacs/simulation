ad_page_contract {
    Details for a task
} {
    enabled_action_id:integer
}

# TODO: Get case_id from action

workflow::case::enabled_action_get -enabled_action_id $enabled_action_id -array enabled_action

simulation::action::get -action_id $enabled_action(action_id) -array action

set case_id $enabled_action(case_id)

set title "Task"
set context [list [list . "SimPlay"] [list [export_vars -base case { case_id }] "Case"] [list [export_vars -base tasks { case_id }] "Tasks"] $title]

ad_form -name action -edit_buttons { { Send ok } } -export { enabled_action_id } -form {
    {pretty_name:text(inform)
        {label "Task"}
    }
    {description:richtext,optional
        {label "Description"}
        {mode display}
    }
    {documents:text(inform),optional
        {label "Documents"}
    }
    {recipient_name:text(inform),optional
        {label "To"}
    }
    {sender_name:text(inform),optional
        {label "From"}
    }
    {subject:text
        {label "Subject"}
        {html {size 80}}
    }
    {body:richtext
        {label "Body"}
        {html {cols 60 rows 20}}
    }
    {attachments:text(inform)
        {label "Attachments"}
        {value "TODO"}
    }
} -on_request {
    set pretty_name $action(pretty_name)
    set description [template::util::richtext::create $action(description) $action(description_mime_type)]
    set document "TODO"

    set recipient_name [simulation::role::get_element -role_id $action(recipient) -element pretty_name]
    set sender_name [simulation::role::get_element -role_id $action(assigned_role_id) -element pretty_name]
}
