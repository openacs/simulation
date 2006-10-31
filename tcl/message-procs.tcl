ad_library {
    Procs to handle sim_messages
}

namespace eval simulation {}
namespace eval simulation::message {}


ad_proc -public simulation::message::new {
    -from_role_id:required
    -to_role_id:required
    -case_id:required
    -subject:required
    {-body {}}
    {-body_mime_type "text/plain"}
    {-item_id {}}
    {-parent_id {}}
    {-content_type "sim_message"}
    {-item_name ""}
    {-attachments ""}
    {-entry_id {}}
} {
    Create new simulation message.
    
    @return item_id of the new message
} {
    db_transaction {
        
        if { [empty_string_p $parent_id] } {
            set parent_id [bcms::folder::get_id_by_package_id -parent_id 0]
        }
        
        if { [empty_string_p $item_id] } {
            set item_id [db_nextval "acs_object_id_seq"]
        }

        if { [empty_string_p $item_name] } {
            set item_name "message_$item_id"
        }
        
        set item_id [bcms::item::create_item \
                         -item_id $item_id \
                         -item_name $item_name \
                         -parent_id $parent_id \
                         -content_type $content_type]
        
        set attributes [list \
                            [list from_role_id $from_role_id] \
                            [list to_role_id $to_role_id] \
                            [list case_id $case_id] \
                            [list entry_id $entry_id]]
        
        set revision_id [bcms::revision::add_revision \
                             -item_id $item_id \
                             -title $subject \
                             -content_type "sim_message" \
                             -mime_type $body_mime_type \
                             -content $body \
                             -additional_properties $attributes]
        
        bcms::revision::set_revision_status \
            -revision_id $revision_id \
            -status "live"

        
        foreach attachment_id $attachments {
            bcms::item::relate_item \
                -relation_tag "attachment" \
                -item_id $item_id \
                -related_object_id $attachment_id
        }

        # Send notification to receiving users
        set users_in_receiving_role [list]
        foreach user_list [workflow::case::role::get_assignees -case_id $case_id -role_id $to_role_id] {
            array set user $user_list
            lappend users_in_receiving_role $user(party_id)
        }
        workflow::case::get -case_id $case_id -array case
        workflow::get -workflow_id $case(workflow_id) -array workflow

        # I18N message variables:
        set simulation_name $workflow(pretty_name)
        set package_id [ad_conn package_id]
        set simplay_url \
            [export_vars -base "[ad_url][apm_package_url_from_id $package_id]simplay" { workflow_id }]

        set notif_subject [_ simulation.message_notificaiton_email_subject]
        set notif_body [_ simulation.message_notification_email_body]

        notification::new \
            -type_id [notification::type::get_type_id -short_name [simulation::notification::message::type_short_name]] \
            -object_id [ad_conn package_id] \
            -notif_subject $notif_subject \
            -notif_text $notif_body \
            -action_id $item_id \
            -subset $users_in_receiving_role
    }
    
    return $item_id
}

ad_proc -public simulation::message::exclude_task_messages_sql {} {
    Return a SQL where clause that will exclude received messages that will
    be responded to with an assigned task instead of by sending a message. The
    need for this query arises because we don't want ask info type message to show up both in
    the message list and the task list. Instead they should show up only in the task list.

    The clause uses the bind variable role_id and assumes sm_messagesx to be in the from clause
    aliased as sm.

    NOTE: This proc is currently not used since Leiden expressed in a discussion that they want all 
          messages to show up after all (even though I warned them that
          some users may respond to a message thinking this will execute the task, but it won't, thus ending up sending
          two messages when they figure out they have to click on the task).

    @author Peter Marklund
} {
    return "(sm.entry_id is null or not (
                                      -- The whole expression in the not parenthesis is true if there is an assigned action
                                      -- responding to the message in which case the message shouldnt show up in the message list

                                      -- message is associated with an action that put us in the current state
                                      sm.entry_id in (select max(wcl.entry_id)
                                                 from workflow_case_log wcl,
                                                      workflow_fsm_actions wfa,
                                                      workflow_case_fsm wcf,
                                                      sim_messagesx sm2
                                                 where wcl.case_id = sm.case_id
                                                   and wcl.action_id = wfa.action_id
                                                   and wcf.case_id = wcl.case_id
                                                   and wfa.new_state = wcf.current_state
                                                   and sm2.entry_id = wcl.entry_id
                                                   and sm2.to_role_id = :role_id
                                                       )
                                       and
                                       -- There is an assigned action with a recipient being sender of the message
                                       exists (select 1 
                                             from workflow_case_assigned_actions wcaa,
                                                  sim_task_recipients str
                                             where wcaa.case_id = sm.case_id
                                             and wcaa.role_id = :role_id
                                             and str.task_id = wcaa.action_id
                                             and str.recipient = sm.from_role_id)
                                      ))"
}

ad_proc -public simulation::message::delete {
    -message_id:required
    -role_id:required
    -case_id:required
} {
    Set the status of a message to deleted.
    
    @return item_id of the deleted message
} {        
    return [delete_or_undelete -action "delete" -message_id $message_id -role_id $role_id -case_id $case_id]
}

ad_proc -public simulation::message::undelete {
    -message_id:required
    -role_id:required
    -case_id:required
} {
    Set the status of a message to normal.
    
    @return item_id of the undeleted message
} {        
    return [delete_or_undelete -action "undelete" -message_id $message_id -role_id $role_id -case_id $case_id]
}

ad_proc -private simulation::message::delete_or_undelete {
    -message_id:required
    -role_id:required
    -case_id:required
    {-action "delete"}
} {
    Set the status of a message to either deleted or not deleted.
    
    @return item_id of the deleted/undeleted message
} {
    db_transaction {
      if {[string equal $action "delete"]} {
        db_dml delete "insert into sim_trash values (:message_id, :role_id, :case_id)"
      } else {
        db_dml undelete "
            delete from sim_trash
            where message_id = :message_id 
            and role_id = :role_id
            and case_id = :case_id"
      }
    }
    
    return $message_id
}