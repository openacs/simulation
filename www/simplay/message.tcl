ad_page_contract {
    Create or edit a message.
} {
    item_id:optional
    case_id:optional
    sender_role_id:optional
    recipient_role_id:optional,multiple
    subject:optional
    body_text:optional
    body_mime_type:optional
}

set page_title "Message"
set context [list [list "." "SimPlay"] [list [export_vars -base case { case_id }] "Case"] $page_title]
set package_id [ad_conn package_id]

set workflow_id [workflow::case::get_element -case_id $case_id -element workflow_id]

set from_role_options [list]
foreach role_id [workflow::case::get_user_roles -case_id $case_id] {
    lappend from_role_options [list [workflow::role::get_element -role_id $role_id -element pretty_name] $role_id]
}
# First sender role selected by default
if { ![exists_and_not_null sender_role_id] } {
    set sender_role_id [lindex [lindex $from_role_options 0] 1]
}

set all_role_options [list]
foreach role_id [workflow::role::get_ids -workflow_id $workflow_id] {
    lappend all_role_options [list [workflow::role::get_element -role_id $role_id -element pretty_name] $role_id]
}

set to_role_options [list]
foreach role_id [workflow::role::get_ids -workflow_id $workflow_id] {
    # A role cannot send message to himself
    if { ![exists_and_equal sender_role_id $role_id] } {
        lappend to_role_options [list [workflow::role::get_element -role_id $role_id -element pretty_name] $role_id]
    }
}

set attachment_options [db_list_of_lists attachment_for_role {
    select cr.title as document_title,
           scrom.object_id as document_id
    from sim_case_role_object_map scrom,
         cr_items ci,
         cr_revisions cr
    where scrom.case_id = :case_id
      and scrom.role_id = :sender_role_id
      and scrom.object_id = ci.item_id
      and ci.live_revision = cr.revision_id
    order by scrom.order_n
}]

set action [form::get_action message]


if { [string equal $action "reply"] } {

    item::get_content \
        -item_id $item_id \
        -array content

    set recipient_role_id $content(from_role_id)
    set sender_role_id $content(to_role_id)
    set subject "Re: $content(title)"
    set body_text "


-----Original Message-----
From: [workflow::role::get_element -role_id $content(from_role_id) -element pretty_name]
Sent: [lc_time_fmt $content(creation_date) "%x %X"]
To: [workflow::role::get_element -role_id $content(to_role_id) -element pretty_name]
Subject: $content(title)

[ad_html_text_convert -from $content(mime_type) -to "text/plain" $content(text)]"
    set body_mime_type "text/plain"

    ad_returnredirect [export_vars -base [ad_conn url] { case_id sender_role_id recipient_role_id subject body_text body_mime_type }]
}

ad_form \
    -name message \
    -edit_buttons { { Send ok } } \
    -actions { { Reply reply } } \
    -export { case_id } \
    -mode [ad_decode [ad_form_new_p -key item_id] 1 "edit" "display"] \
    -form {
        {sender_role_id:text(select)
            {label "From"}
            {html {onChange "javascript:FormRefresh('message');"}}
            {options $all_role_options}
        }
    }

if { [llength $from_role_options] > 1 } {
    set focus "message.sender_role_id"
} else {
    set sender_role_id [lindex [lindex $from_role_options 0] 1]
    set focus "message.recipient_role_id"
}

ad_form -extend -name message -form {
    {item_id:key}
    {recipient_role_id:integer(checkbox),multiple
        {label "To"}
        {options $to_role_options}
    }
    {subject:text
        {label "Subject"}
        {html {size 80}}
    }
    {body:richtext
        {label "Body"}
        {html {cols 60 rows 20}}
    }
}

if { [llength $attachment_options] > 0 } {
    ad_form -extend -name message -form {
        {attachments:integer(checkbox),multiple,optional
            {label "Attachments"}
            {options $attachment_options}
        }
    }
} else {
    ad_form -extend -name message -form {
        {attachments:integer(hidden),optional}
    }
}

ad_form -extend -name message -new_request {
    if { [info exists body_text] } {
        if { ![info exists body_mime_type] } {
            set body_mime_type "text/enhanced"
        }
        set body [template::util::richtext::create $body_text $body_mime_type]
        set focus "message.body"
    }

    if { [llength $from_role_options] == 1 } {
        set sender_role_id [lindex [lindex $from_role_options 0] 1]
        element set_properties message sender_role_id -mode display
    } else {
        element set_properties message sender_role_id -options $from_role_options
    }
} -edit_request {
    
    item::get_content \
        -item_id $item_id \
        -array content

    # Don't show checkboxes, just show the current role
    element set_properties message recipient_role_id -widget select

    set sender_role_id $content(from_role_id)
    set recipient_role_id $content(to_role_id)
    set subject $content(title)
    set body [template::util::richtext::create $content(text) $content(mime_type)]

    set attachments_set_list [bcms::item::list_related_items \
                             -item_id $item_id \
                             -relation_tag attachment \
                             -return_list]
    set attachments [list]
    foreach attachment_set $attachments_set_list {
        lappend attachments [ns_set get $attachment_set item_id]
    }

} -on_submit {

    set body_text [template::util::richtext::get_property "contents" $body]
    set body_mime_type [template::util::richtext::get_property "format" $body]

    db_transaction {
    
        set parent_id [bcms::folder::get_id_by_package_id -parent_id 0]
        
        foreach to_role_id $recipient_role_id {
            simulation::message::new \
                -from_role_id $sender_role_id \
                -to_role_id $to_role_id \
                -case_id $case_id \
                -subject $subject \
                -body $body_text \
                -body_mime_type $body_mime_type \
                -attachments $attachments
        }
    }

    ad_returnredirect [export_vars -base case { case_id }]
    ad_script_abort
}
