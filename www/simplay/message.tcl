ad_page_contract {
    Create or edit a message.
} {
    item_id:optional
    case_id:optional
    sender_role_id:optional
    recipient_role_id:optional
    subject:optional
    body_text:optional
    body_mime_type:optional
}

set page_title "Message"
set context [list [list "." "SimPlay"] [list $page_title] ]
set package_id [ad_conn package_id]

set workflow_id [workflow::case::get_element -case_id $case_id -element workflow_id]

set from_role_options [list]
foreach role_id [workflow::case::get_user_roles -case_id $case_id] {
    lappend from_role_options [list [workflow::role::get_element -role_id $role_id -element pretty_name] $role_id]
}

set to_role_options [list]
foreach role_id [workflow::role::get_ids -workflow_id $workflow_id] {
    lappend to_role_options [list [workflow::role::get_element -role_id $role_id -element pretty_name] $role_id]
}

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
        {item_id:key}
        {sender_role_id:text(select)
            {label "From"}
            {options $from_role_options}
        }
    }

if { [llength $from_role_options] > 1 } {
    set focus "message.sender_role_id"
} else {
    set sender_role_id [lindex [lindex $from_role_options 0] 1]
    set focus "message.recipient_role_id"
}


ad_form -extend -name message -form {
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
    {attachments:text(inform)
        {label "Attachments"}
        {value "TODO"}
    }
} -on_request {
    if { [llength $from_role_options] == 1 } {
        set sender_role_id [lindex [lindex $from_role_options 0] 1]
        element set_properties message mode display
    }
} -new_request {
    if { [info exists body_text] } {
        if { ![info exists body_mime_type] } {
            set body_mime_type "text/enhanced"
        }
        set body [template::util::richtext::create $body_text $body_mime_type]
        set focus "message.body"
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
} -on_submit {

    set body_text [template::util::richtext::get_property "contents" $body]
    set body_mime_type [template::util::richtext::get_property "format" $body]

    db_transaction {
    
        set parent_id [bcms::folder::get_id_by_package_id -parent_id 0]
        
        foreach to_role_id $recipient_role_id {
            simulation::message::new \
                -item_id $item_id \
                -from_role_id $sender_role_id \
                -to_role_id $to_role_id \
                -case_id $case_id \
                -subject $subject \
                -body $body_text \
                -body_mime_type $body_mime_type
        }
    }

    ad_returnredirect [export_vars -base case { case_id }]
    ad_script_abort
}
