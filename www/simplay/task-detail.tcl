ad_page_contract {
    Details for a task. If there is a recipient_role a message is created. If there
    is not recipient role we upload a document instead.
} {
    case_id:integer
    role_id:integer
    enabled_action_id:integer
    item_id:optional
}

simulation::case::assert_user_may_play_role -case_id $case_id -role_id $role_id

workflow::case::enabled_action_get -enabled_action_id $enabled_action_id -array enabled_action
set action_id $enabled_action(action_id)
simulation::action::get -action_id $action_id -array action

set page_title $action(pretty_name)
set context [list [list . "SimPlay"] [list [export_vars -base case { case_id role_id }] "Case"] [list [export_vars -base tasks { case_id role_id }] "Tasks"] $page_title]

if { ![empty_string_p $action(recipients)] } {
    # We have recipient roles - use message form

    if { ![empty_string_p $action(assigned_role_id)] } {
        set attachment_options [simulation::case::attachment_options -case_id $case_id -role_id $action(assigned_role_id)]
    }

    set form_id action

    ad_form -name $form_id -edit_buttons { { Send ok } } -export { case_id role_id enabled_action_id } \
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
            
            ad_returnredirect [export_vars -base tasks { case_id role_id }]
            ad_script_abort
        }

    set focus "action.subject"
} else {
    # No recipient roles - use upload document form

    set workflow_id [workflow::case::get_element -case_id $case_id -element workflow_id]

    set form_id document

    ad_form -name $form_id -export { case_id role_id workflow_id enabled_action_id } -html {enctype multipart/form-data} \
        -form [concat {{pretty_name:text(inform) {label "Task"}}} [simulation::ui::forms::document_upload::form_block]] \
        -on_request {
            set pretty_name $action(pretty_name)
            set documents_pre_form [simulation::ui::forms::document_upload::documents_element_value $action_id]

        } -on_submit {

            db_transaction {
                set entry_id [workflow::case::action::execute \
                                  -case_id $case_id \
                                  -action_id $action_id \
                                  -comment "Document [lindex $document_file 0] uploaded" \
                                  -comment_mime_type "text/plain"]

                simulation::ui::forms::document_upload::insert_document \
                    $case_id $role_id $item_id $document_file $title $entry_id
            }

            ad_returnredirect [export_vars -base tasks { case_id role_id }]
        }

    set focus "document.document_file"    
}

