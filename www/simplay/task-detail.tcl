ad_page_contract {
    Details for a task
} {
    enabled_action_id:integer
}

workflow::case::enabled_action_get -enabled_action_id $enabled_action_id -array enabled_action

set case_id $enabled_action(case_id)
set action_id $enabled_action(action_id)

simulation::action::get -action_id $action_id -array action

if { ![empty_string_p $action(assigned_role_id)] } {
    set attachment_options [simulation::case::attachment_options -case_id $case_id -role_id $action(assigned_role_id)]
}

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
    {sender_name:text(inform),optional
        {label "From"}
    }
    {recipient_name:text(inform),optional
        {label "To"}
    }
    {subject:text
        {label "Subject"}
        {html {size 80}}
    }
    {body:richtext
        {label "Body"}
        {html {cols 60 rows 20}}
    }
    {attachments:integer(checkbox),multiple,optional
        {label "Attachments"}
        {options $attachment_options}
    }
} -on_request {
    set pretty_name $action(pretty_name)
    set description [template::util::richtext::create $action(description) $action(description_mime_type)]

    set documents {}
    db_foreach documents {
        select cr.title as object_title,
               ci.name as object_name
        from   sim_task_object_map m,
               cr_items ci,
               cr_revisions cr
        where  m.task_id = :action_id
        and    m.relation_tag = 'attachment'
        and    ci.item_id = m.object_id
        and    cr.revision_id = ci.live_revision
        order by m.order_n
    } {
        set object_url [simulation::object::url \
                            -name $object_name]
        append documents "<a href=\"$object_url\">$object_title</a><br>"
    }

    if { ![empty_string_p $action(recipient)] } {
        set recipient_name [simulation::role::get_element -role_id $action(recipient) -element pretty_name]
    }
    if { ![empty_string_p $action(assigned_role_id)] } {
        simulation::role::get -role_id $action(assigned_role_id) -array sender_role
        set sender_name $sender_role(pretty_name)
    }
} -on_submit {

    set body_text [template::util::richtext::get_property "contents" $body]
    set body_mime_type [template::util::richtext::get_property "format" $body]

    db_transaction {
    
        workflow::case::action::execute \
            -case_id $case_id \
            -action_id $action_id \
            -comment $body_text \
            -comment_mime_type $body_mime_type
        
        simulation::message::new \
            -from_role_id $action(assigned_role_id) \
            -to_role_id $action(recipient) \
            -case_id $case_id \
            -subject $subject \
            -body $body_text \
            -body_mime_type $body_mime_type \
            -attachments $attachments
    }

    ad_returnredirect [export_vars -base tasks { case_id }]
    ad_script_abort
}
