ad_page_contract {
    Details for a task. If there is a recipient_role a message is created. If there
    is not recipient role we upload a document instead.
} {
    {enabled_action_id:integer,multiple ""}
    {enabled_action_ids ""}
    item_id:optional
    {bulk_p 0}
    {return_url ""}
    subject:optional
    body:optional    
}

# FIXME: I am exporting the enabled_action_id list as the string variable enabled_action_ids in 
# the forms as I can't export multiples. Here I'm recreating the list again. This is convoluted.
if { ![empty_string_p $enabled_action_ids] } {
    set enabled_action_id [split $enabled_action_ids]
}

if { [llength $enabled_action_id] > 1 } {
    set bulk_p 1
}

if { !$bulk_p } {
    workflow::case::enabled_action_get -enabled_action_id $enabled_action_id -array enabled_action

    set action_id $enabled_action(action_id)
    set case_id $enabled_action(case_id)
    simulation::action::get -action_id $action_id -array action
    set role_id $action(assigned_role_id)

    simulation::case::assert_user_may_play_role -case_id $case_id -role_id $action(assigned_role_id)

    set common_enabled_action_ids [list [list $enabled_action_id $case_id]]

    if { [empty_string_p $return_url] } {
        set return_url [export_vars -base tasks { case_id role_id }]
    }

    if { ![info exists body] } {
        if {[db_0or1row select_triggering_message_id {
            select sm.from_role_id,
                   sm.to_role_id,
                   sm.creation_date,
                   cr.title as subject,
                   cr.content as triggering_body,
                   cr.mime_type as mime_type
            from sim_messagesx sm,
                 cr_revisions cr
            where sm.message_id = cr.revision_id
              and sm.entry_id = (select max(wcl.entry_id)
                                 from workflow_case_log wcl,
                                      workflow_fsm_actions wfa,
                                      workflow_case_fsm wcf
                                 where wcl.case_id = sm.case_id
                                 and wcl.action_id = wfa.action_id
                                 and wcf.case_id = wcl.case_id
                                 and wfa.new_state = wcf.current_state)
              and sm.case_id = :case_id
        }] } {
            set subject "Re: $subject"
            set body "

-----Original Message-----
From: [workflow::role::get_element -role_id $from_role_id -element pretty_name]
Sent: [lc_time_fmt $creation_date "%x %X"]
To: [workflow::role::get_element -role_id $to_role_id -element pretty_name]
Subject: $subject

[ad_html_text_convert -from $mime_type -to "text/plain" $triggering_body]"

            ad_returnredirect [export_vars -base [ad_conn url] { enabled_action_id role_id subject body}]
        }    
    }

} else {
    # Only admin users can neglect to provide case_id and role_id
    permission::require_permission -object_id [ad_conn package_id] -privilege sim_adminplayer    

    # If we are taking action on more than one task, extract the subset of the tasks that
    # have the same action_id
    set common_action_id ""
    set common_enabled_action_ids [list]
    set ignored_enabled_action_ids [list]
    set task_list [db_list_of_lists select_tasks "
        select wcea.enabled_action_id,
               wcea.action_id,
               wcea.case_id
        from workflow_case_enabled_actions wcea
        where wcea.enabled_action_id in ('[join $enabled_action_id "', '"]')
    "]
    foreach task $task_list {
        set one_enabled_action_id [lindex $task 0]
        set one_action_id [lindex $task 1]
        set one_case_id [lindex $task 2]

        if { [empty_string_p $common_action_id] } {
            set common_action_id $one_action_id
            set case_id $one_case_id
        }

        if { [string equal $common_action_id $one_action_id] } {
            lappend common_enabled_action_ids [list $one_enabled_action_id $one_case_id]
        } else {
            lappend ignored_enabled_action_ids $one_enabled_action_id
        }
    }

    set common_actions_count [llength $common_enabled_action_ids]
    set ignored_actions_count [llength $ignored_enabled_action_ids]

    set action_id $common_action_id

    simulation::action::get -action_id $action_id -array action

    if { [empty_string_p $return_url] } {
        set return_url [export_vars -base tasks-bulk { {workflow_id $action(workflow_id)} }]
    }
}

set page_title $action(pretty_name)
set context [list [list . "SimPlay"] [list [export_vars -base case { case_id role_id }] "Case"] [list [export_vars -base tasks { case_id role_id }] "Tasks"] $page_title]
set documents_pre_form ""

if { ![empty_string_p $action(recipients)] } {
    # We have recipient roles - use message form

    if { !$bulk_p } {
        if { ![empty_string_p $action(assigned_role_id)] } {
            set attachment_options [simulation::case::attachment_options -case_id $case_id -role_id $action(assigned_role_id)]
        }
    } else {
        set attachment_options {}
    }

    set form_id action

    ad_form -name $form_id -edit_buttons { { Send ok } } -export { case_id role_id {enabled_action_ids $enabled_action_id} bulk_p} \
        -form {
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
            {recipient_names:text(inform),optional
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

            if { [info exists body] } {
                if { ![info exists body_mime_type] } {
                    set body_mime_type "text/enhanced"
                }
                set body [template::util::richtext::create $body $body_mime_type]
                set focus "action.body"
            }

            set pretty_name $action(pretty_name)
            set description [template::util::richtext::create $action(description) $action(description_mime_type)]

            set documents [simulation::ui::forms::document_upload::documents_element_value $action_id]
            set documents_pre_form ""

            set recipient_list [list]
            foreach recipient_id $action(recipients) {
                lappend recipient_list [simulation::role::get_element -role_id $recipient_id -element pretty_name]
            }
            set recipient_names [join $recipient_list ", "]

            if { ![empty_string_p $action(assigned_role_id)] } {
                simulation::role::get -role_id $action(assigned_role_id) -array sender_role
                set sender_name $sender_role(pretty_name)
            }        
        } -on_submit {

            set body_text [template::util::richtext::get_property "contents" $body]
            set body_mime_type [template::util::richtext::get_property "format" $body]

            db_transaction {
                foreach one_action $common_enabled_action_ids {
                    set enabled_action_id [lindex $one_action 0]
                    set case_id [lindex $one_action 1]

                    set entry_id [workflow::case::action::execute \
                                  -enabled_action_id $enabled_action_id \
                                  -comment $body_text \
                                  -comment_mime_type $body_mime_type]
                
                    foreach recipient_id $action(recipients) {
                        simulation::message::new \
                            -from_role_id $action(assigned_role_id) \
                            -to_role_id $recipient_id \
                            -case_id $case_id \
                            -subject $subject \
                            -body $body_text \
                            -body_mime_type $body_mime_type \
                            -attachments $attachments \
                            -entry_id $entry_id
                    }
                }
            }
            
            ad_returnredirect $return_url
            ad_script_abort
        }

    set focus "action.subject"
} else {
    # No recipient roles - use upload document form

    set workflow_id [workflow::case::get_element -case_id $case_id -element workflow_id]

    set form_id document

    ad_form -name $form_id -export { case_id role_id workflow_id {enabled_action_ids $enabled_action_id} bulk_p} -html {enctype multipart/form-data} \
        -form [concat {{pretty_name:text(inform) {label "Task"}}} [simulation::ui::forms::document_upload::form_block]] \
        -on_request {
            set pretty_name $action(pretty_name)
            set documents_pre_form [simulation::ui::forms::document_upload::documents_element_value $action_id]

        } -on_submit {

            db_transaction {
                foreach one_action $common_enabled_action_ids {
                    set case_id [lindex $one_action 1]

                    set entry_id [workflow::case::action::execute \
                                  -case_id $case_id \
                                  -action_id $action_id \
                                  -comment "Document [lindex $document_file 0] uploaded" \
                                  -comment_mime_type "text/plain"]

                    simulation::ui::forms::document_upload::insert_document \
                        $case_id $action(assigned_role_id) $item_id $document_file $title $entry_id
                }
            }

            ad_returnredirect $return_url
            ad_script_abort
        }

    set focus "document.document_file"    
}
