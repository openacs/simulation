ad_page_contract {
    Show task description and props for editing.

    @author Joel Aufrecht
} {
    action_id:integer
}

set user_id [auth::require_login]

workflow::action::fsm::get -action_id $action_id -array task_array

# TODO: Move into simulation::action::get API
db_1row select_recipient {
    select recipient as recipient_role_id, attachment_num
    from sim_tasks
    where task_id = :action_id
} -column_array task_array2
array set task_array [array get task_array2]

set workflow_id $task_array(workflow_id)
permission::require_write_permission -object_id $workflow_id

workflow::get -workflow_id $workflow_id -array workflow_array
set role_options [workflow::role::get_options -workflow_id $workflow_id]

set page_title "Edit $task_array(pretty_name)"
set return_url [export_vars -base map-tasks { workflow_id }]
set context [list [list "." "SimInst"] [list $return_url "Tasks for $workflow_array(pretty_name)"] $page_title]

ad_form -name task -export { workflow_id } -edit_buttons [list [list [ad_decode [ad_form_new_p -key action_id] 1 [_ acs-kernel.common_add] [_ acs-kernel.common_update]] ok]] -form {
    {action_id:key}
    {pretty_name:text
        {label "Task Name"}
        {html {size 20}}
        {mode display}
    }
    {assigned_role:text(select),optional
        {label "Assigned To"}
        {options $role_options}
        {mode display}
    }
    {recipient_role:text(select),optional
        {label "Recipient"}
        {options $role_options}
        {mode display}
    }
    {description:richtext,optional
        {label "Task Description"}
        {html {cols 60 rows 8}}
    }
    {attachment_num:integer(text)
        {label "Number of attachments"}
        {help_text "These are placeholders that are matched to props by the case author during SimInst"}
        {html {size 2}}
        {mode display}
    }
}

set prop_options [simulation::object::get_object_type_options -object_type "sim_prop"]

for { set i 1 } { $i <= $task_array(attachment_num) } { incr i } {
    ad_form -extend -name task -form [list [list attachment_$i:integer(select),optional [list label "Attachment $i"] [list options \$prop_options]]]
        
}


ad_form -extend -name task -edit_request {
    set pretty_name $task_array(pretty_name)
    set description [template::util::richtext::create $task_array(description) $task_array(description_mime_type)]
    set new_state_id $task_array(new_state_id)
    set attachment_num $task_array(attachment_num)
    
    if { ![empty_string_p $task_array(recipient_role_id)] } {
        set recipient_role [workflow::role::get_element -role_id $task_array(recipient_role_id) -element short_name]
    } else {
        set recipient_role {}
    }
    set assigned_role $task_array(assigned_role)

    db_foreach attachments {
        select object_id,
               order_n
        from   sim_task_object_map 
        where  task_id = :action_id
        and    relation_tag = 'attachment'
    } {
        if { $order_n >= 1 && $order_n <= $task_array(attachment_num) } {
            set attachment_$order_n $object_id
        }
    }
} -on_submit {
    
    set description_mime_type [template::util::richtext::get_property format $description]
    set description [template::util::richtext::get_property contents $description]

    if { ![empty_string_p $recipient_role] } {
        set recipient_role_id [workflow::role::get_id -workflow_id $workflow_id -short_name $recipient_role]
    } else {
        set recipient_role_id [db_null]
    }
} -edit_data {
    # We use task_array(workflow_id) here, which is gotten from the DB, and not
    # workflow_id, which is gotten from the form, because the workflow_id from the form 
    # could be spoofed
    permission::require_write_permission -object_id $task_array(workflow_id)

    array unset row
    foreach col { description description_mime_type } {
        set row($col) [set $col]
    }

    db_transaction {
        simulation::action::edit \
            -action_id $action_id \
            -workflow_id $task_array(workflow_id) \
            -array row
        
        # TODO: The way we do this update is not very pretty: Delete all relations and re-add the new ones
        db_dml delete_all_relations {
            delete from sim_task_object_map
            where  task_id = :action_id
        }

        for { set i 1 } { $i <= $task_array(attachment_num) } { incr i } {
            set elm "attachment_$i"
            set related_object_id [set $elm]
            
            if { ![empty_string_p $related_object_id] } {
                db_dml insert_rel {
                    insert into sim_task_object_map (task_id, object_id, order_n, relation_tag)
                    values (:action_id, :related_object_id, :i, 'attachment')
                }
            }
        }
        
    }
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}
