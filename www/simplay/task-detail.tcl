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
    received_message_item_id:optional
    case_id
    role_id
}


# FIXME: I am exporting the enabled_action_id list as the string variable enabled_action_ids in 
# the forms as I can't export multiples. Here I'm recreating the list again. This is convoluted.
if { ![empty_string_p $enabled_action_ids] } {
    set enabled_action_id [split $enabled_action_ids]
}

if { [llength $enabled_action_id] > 1 } {
    set bulk_p 1
} 

if { [empty_string_p $return_url] } {
    set return_url [export_vars -base case { case_id role_id }]
}

if { [llength $enabled_action_id] == 1 } {
    
    # Check that no other player has changed the state while
    # we have been filling in the form.
    if { [catch {
	workflow::case::enabled_action_get -enabled_action_id $enabled_action_id -array enabled_action
    }] } {
	ad_returnredirect -message "<p><strong>[_ simulation.Sorry]</strong> [_ simulation.lt_The_task_you_were_try]</p> <p>[_ simulation.lt_Someone_was_probably_]</p>" \
	    -html $return_url
	ad_script_abort
    }
    set action_id $enabled_action(action_id)
    set case_id $enabled_action(case_id)
    simulation::action::get -action_id $action_id -array action
    set role_id $action(assigned_role_id)

    simulation::case::assert_user_may_play_role -case_id $case_id -role_id $action(assigned_role_id)

    set common_enabled_action_ids [list [list $enabled_action_id $case_id]]

    set common_actions_count 1
    set ignored_actions_count 0

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
set context [list [list . [_ simulation.SimPlay]] \
            [list [export_vars -base case { case_id role_id }] [_ simulation.Case]] \
            [list [export_vars -base tasks { case_id role_id }] [_ simulation.Tasks]] \
            $page_title]
set documents_pre_form ""

set document_upload_url [export_vars -base document-upload {case_id role_id {return_url {[ad_return_url]}}}]

if { [empty_string_p $action(recipients)] } {
    set message_p false
} else {
    set message_p true
}

if { $message_p } {
    # We have recipient roles - use message form

    if { !$bulk_p } {
        if { ![empty_string_p $action(assigned_role_id)] } {
            set attachment_options [simulation::case::attachment_options -case_id $case_id -role_id $action(assigned_role_id)]
        }
    } else {
        set attachment_options {}
    }

    set form_id action

    ad_form -name $form_id -edit_buttons { { Send ok } } -cancel_url $return_url -export { case_id role_id {enabled_action_ids $enabled_action_id} bulk_p} \
        -form {
            {pretty_name:text(inform)
                {label {[_ simulation.Task]}}
            }
            {description:richtext,optional
                {label {[_ simulation.Description]}}
                {mode display}
            }
            {documents:text(inform),optional
                {label {[_ simulation.Documents]}}
            }
            {sender_name:text(inform),optional
                {label {[_ simulation.From]}}
            }
            {recipient_names:text(inform),optional
                {label {[_ simulation.To]}}
            }
            {subject:text
                {label {[_ simulation.Subject]}}
                {html {size 80}}
            }
            {body:richtext
                {label {[_ simulation.Body]}}
                {html {cols 60 rows 20}}
            }
            {attachments:integer(checkbox),multiple,optional
                {label {[_ simulation.Attachments]}}
                {options $attachment_options}
            }        
        } -on_request {

            if { [info exists body] } {
                if { ![info exists body_mime_type] } {
                    set body_mime_type "text/enhanced"
                }
                set body [template::util::richtext::create $body $body_mime_type]
                set focus "action.body"
            } else {
		if { ![empty_string_p $action(default_text)] } {
		    set body [template::util::richtext::create $action(default_text) $action(default_text_mime_type)]
		    set body_mime_type $action(default_text_mime_type)
		}
	    }

            set pretty_name $action(pretty_name)
            set description [template::util::richtext::create $action(description) $action(description_mime_type)]

            set documents [simulation::ui::forms::document_upload::documents_element_value_content \
			       $action_id]

	    # Let's tell users if there's no attachments instead of giving
	    # them an empty <ul> pair.
	    if { [string match "<ul></ul>" $documents] } {
		set documents "<em>[_ simulation.no_attachments]</em>"
	    }

            set documents_pre_form ""

            set recipient_list [list]
            foreach recipient_id $action(recipients) {
		simulation::role::get -role_id $recipient_id -array recipient_role
                lappend recipient_list "$recipient_role(pretty_name) ($recipient_role(character_title))"
            }
            set recipient_names [join $recipient_list ", "]

            if { ![empty_string_p $action(assigned_role_id)] } {
                simulation::role::get -role_id $action(assigned_role_id) -array sender_role
                set sender_name "$sender_role(pretty_name) ($sender_role(character_title))"
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

    set documents_pre_form [simulation::ui::forms::document_upload::documents_element_value_content $action_id]
    set documents_pre_form_empty_p [string match "<ul></ul>" $documents_pre_form]

    ad_form -name $form_id \
        -export { case_id role_id workflow_id {enabled_action_ids $enabled_action_id} bulk_p} \
	-cancel_url $return_url \
        -html {enctype multipart/form-data} \
        -form [concat {{pretty_name:text(inform) {label {[_ simulation.Task]}}}} \
           [simulation::ui::forms::document_upload::form_block]] \
        -on_request {
            set pretty_name $action(pretty_name)
            set description [template::util::richtext::create $action(description) $action(description_mime_type)]
        } -validate {
	    {document_file 
		{[simulation::ui::forms::document_upload::check_mime -document_file $document_file]}
		"[_ simulation.lt_The_mime_type_of_your] [_ simulation.lt_Please_contact_______] 
             (<a href='mailto:[ad_host_administrator]'>[ad_host_administrator]</a>)
             [_ simulation.lt_if_you_think_youre_up]"
	    }
	} -on_submit {
	    

            db_transaction {
                foreach one_action $common_enabled_action_ids {
                    set case_id [lindex $one_action 1]
		    
                    set document [lindex $document_file 0]
                    set entry_id [workflow::case::action::execute \
                                  -case_id $case_id \
                                  -action_id $action_id \
                                  -comment [_ simulation.lt_Document_document_upl] \
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
