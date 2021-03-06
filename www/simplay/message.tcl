ad_page_contract {
    Create or edit a message.
} {
    item_id:integer,optional
    case_id:integer
    role_id:integer
    recipient_role_id:integer,optional,multiple
    subject:optional
    body_text:optional
    body_mime_type:optional
}

simulation::case::assert_user_may_play_role -case_id $case_id -role_id $role_id

set page_title [_ simulation.Message]
set context [list [list "." [_ simulation.SimPlay]] [list [export_vars -base case { case_id role_id }] [_ simulation.Case]] $page_title]
set package_id [ad_conn package_id]

set return_url [export_vars -base case { case_id role_id }]

set workflow_id [workflow::case::get_element -case_id $case_id -element workflow_id]

set all_role_options [list]
foreach one_role_id [workflow::role::get_ids -workflow_id $workflow_id] {
    set character_title [simulation::role::get_element -role_id $one_role_id -element character_title]
    set pretty_name [simulation::role::get_element -role_id $one_role_id -element pretty_name]
    lappend all_role_options [list "$pretty_name ($character_title)" $one_role_id]
}

set to_role_options [list]
foreach one_role_id [workflow::role::get_ids -workflow_id $workflow_id] {
    set character_title [simulation::role::get_element -role_id $one_role_id -element character_title]
    set pretty_name [simulation::role::get_element -role_id $one_role_id -element pretty_name]
        lappend to_role_options [list "$pretty_name ($character_title)" $one_role_id]
}

set attachment_options [simulation::case::attachment_options -case_id $case_id -role_id $role_id]

set document_upload_url [export_vars -base document-upload {case_id role_id {return_url {[ad_return_url]}}}]

set action [form::get_action message]


if { [string equal $action "reply"] } {

    item::get_content \
        -item_id $item_id \
        -array content

    set sender_role_id $content(from_role_id)
    set subject "[_ simulation.Re] $content(title)"
    set sender_pretty_name [simulation::role::get_element -role_id $sender_role_id -element pretty_name]
    set sender_character_title [simulation::role::get_element -role_id $sender_role_id -element character_title]
    set recipient_pretty_name [simulation::role::get_element -role_id $content(to_role_id) \
				   -element pretty_name]
    set recipient_character_title [simulation::role::get_element -role_id $content(to_role_id) \
				   -element character_title]
    set body_text "



-----Original Message-----
From: $sender_pretty_name ($sender_character_title)
Sent: [lc_time_fmt $content(creation_date) "%x %X"]
To: $recipient_pretty_name ($recipient_character_title)
Subject: $content(title)

[ad_html_text_convert -from $content(mime_type) -to "text/plain" $content(text)]"
    set body_mime_type "text/plain"

    ad_returnredirect [export_vars -base [ad_conn url] { case_id role_id recipient_role_id subject body_text body_mime_type }]
}

set form_new_p [ad_form_new_p -key item_id]

set form_mode [ad_decode $form_new_p 1 "edit" "display"]

set focus "message.recipient_role_id"

set sender_role_id $role_id

ad_form \
    -name message \
    -edit_buttons { { Send ok } } \
    -export { case_id role_id } \
    -mode $form_mode \
    -cancel_url $return_url \
    -form {
        {item_id:key}
        {sender_role_id:text(select)
            {label {[_ simulation.From]}}
            {mode display}
            {options $all_role_options}
        }
    }

if { $form_new_p } {
    if { [llength $to_role_options] == 1 } {
        ad_form -extend -name message -form {
            {recipient_role_id_inform:text(inform)
                {label {[_ simulation.To]}}
                {value {[lindex [lindex $to_role_options 0] 0]}}
            }
            {recipient_role_id:integer(hidden)
                {value {[lindex [lindex $to_role_options 0] 1]}}
            }
        }
    } else {
        ad_form -extend -name message -form {
            {recipient_role_id:integer(checkbox),multiple
                {label {[_ simulation.To]}}
                {options $to_role_options}
            }
        }
    }
} else {
    ad_form -extend -name message -form {
        {recipient_role_id:integer(checkbox),multiple
            {label {[_ simulation.To]}}
            {options $to_role_options}
        }
    }
}



ad_form -extend -name message -form {
    {subject:text
        {label {[_ simulation.Subject]}}
        {html {size 80}}
    }
    {body:richtext
        {label {[_ simulation.Body]}}
        {html {cols 60 rows 20}}
    }
}

if { !$form_new_p } {
    set attachments_set_list [bcms::item::list_related_items \
				  -revision live \
				  -item_id $item_id \
				  -relation_tag attachment \
				  -return_list]
}

if { ![string equal $form_mode "display"] } {
    if { [llength $attachment_options] > 0 } {
        # edit/new mode - show checkboxes        
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
} elseif { [llength $attachments_set_list] > 0 } {
    # display mode - show a list of attached documents
    ad_form -extend -name message -form {
	{attachments:text(inform),optional
	    {label {[_ simulation.Attachments]}}
	}
    }
}  else {
    # this is just to avoid ad_form freakin' out because it needs a
    # field called attachments
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

    if { $recipient_role_id == $role_id } {
        form set_properties message -actions { { Reply reply } }
    } else {
        form set_properties message -actions { }
    }

    if { ![string equal $form_mode "display"] } {
        # edit/new mode - set checkbox integer values
        set attachments [list]
        foreach attachment_set $attachments_set_list {
            lappend attachments [ns_set get $attachment_set item_id]
        }
    } else {
        # display mode - show a list of attached documents
        set attachments ""
        foreach attachment_set $attachments_set_list {
            set object_url [simulation::object::content_url -name [ns_set get $attachment_set name]]
            set object_title [ns_set get $attachment_set title].
            set mime_type [ns_set get $attachment_set mime_type]
            append attachments "<a href=\"$object_url\">$object_title</a> ($mime_type)<br>"
        }
        if { [llength $attachments_set_list] == 0 } {
            element set_properties message attachments -widget hidden
        }
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

    ad_returnredirect $return_url
    ad_script_abort
}

if { ![ad_form_new_p -key item_id] } {
    element set_properties message recipient_role_id -options $all_role_options
}

