ad_page_contract {
    Details for a task
} {
    enabled_action_id:integer
}

# TODO: Get case_id from action

workflow::case::enabled_action_get -enabled_action_id $enabled_action_id -array enabled_action

set case_id $enabled_action(case_id)
set action_id $enabled_action(action_id)

simulation::action::get -action_id $action_id -array action

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
        set sender_name [simulation::role::get_element -role_id $action(assigned_role_id) -element pretty_name]
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
        
        # Send message
        
        set to_role_id $action(recipient)
        set from_role_id $action(assigned_role_id)
        
        set parent_id [bcms::folder::get_id_by_package_id -parent_id 0]
        
        set item_id [db_nextval "acs_object_id_seq"]
        
        set item_id [bcms::item::create_item \
                         -item_id $item_id \
                         -item_name "message_$item_id" \
                         -parent_id $parent_id \
                         -content_type "sim_message"]
        
        set attributes [list \
                            [list from_role_id $from_role_id] \
                            [list to_role_id $to_role_id] \
                            [list case_id $case_id]]
        
        set revision_id [bcms::revision::add_revision \
                             -item_id $item_id \
                             -title $subject \
                             -content_type "sim_message" \
                             -mime_type $body_mime_type \
                             -content $body_text \
                             -additional_properties $attributes]
    }

    ad_returnredirect [export_vars -base tasks { case_id }]
    ad_script_abort
}
