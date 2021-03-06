ad_page_contract {
    Display and edit the task descriptions and attachments of a simulation.

    @author Peter Marklund
} {
    workflow_id:integer
}

permission::require_write_permission -object_id $workflow_id

set user_id [auth::require_login]

ad_form \
    -name tasks \
    -form { 
        {workflow_id:integer(hidden) {value $workflow_id}}
    }

set prop_options [simulation::object::get_object_type_options -object_type "sim_prop" -null_label "--Not Yet Selected--"]

set prop_count [llength $prop_options]
set missing_props_p 0

set actions [list]

db_foreach tasks {
    select a.action_id,
           a.pretty_name,
           a.description,
           a.description_mime_type,
           st.default_text,
           st.default_text_mime_type,
           st.attachment_num,
           (select pretty_name from workflow_roles where role_id = a.assigned_role) as assigned_role_pretty
    from   workflow_actions a,
           sim_tasks st
    where  a.workflow_id = :workflow_id
    and    st.task_id = a.action_id
    and    a.trigger_type = 'user'
    order  by a.sort_order
} -column_array row {
    set section_name "Task $row(pretty_name)"
    # TODO B: use a grouping query instead of this query in a query
    set action_id $row(action_id)
    set recipient_role_list [db_list select_recipient_roles {
        select wr.pretty_name
        from sim_task_recipients str,
             workflow_roles wr
        where str.task_id = :action_id
          and str.recipient = wr.role_id
    }]
    set recipient_role_pretty [join $recipient_role_list ", "]
    if { ![empty_string_p $row(assigned_role_pretty)] || ![empty_string_p $recipient_role_pretty] } {
        append section_name " ("
        if { ![empty_string_p $row(assigned_role_pretty)] } {
            append section_name "$row(assigned_role_pretty)"
        }
        if { ![empty_string_p $recipient_role_pretty] } {
            append section_name " to $recipient_role_pretty"
        }
    }
    append section_name ")"
    
    ad_form -extend -name tasks -form \
        [list [list description_$row(action_id):richtext,optional \
                   {label "Task Description"} \
                   {help_text "This is the text that users will see while attempting to complete a task."} \
                   {html {cols 60 rows 4}} \
                   {section $section_name} ]]
    set description_$row(action_id) [template::util::richtext::create $row(description) $row(description_mime_type)]

    # Show default message text field if this is a message-type task
    if { ![empty_string_p $recipient_role_pretty] } {
	ad_form -extend -name tasks -form \
	    [list [list default_text_$row(action_id):richtext,optional \
		       {label "Task Default message"} \
		       {help_text "This is the default text that will appear in a message-type task form."} \
		       {html {cols 60 rows 4}} \
		       {section $section_name} ]]
	set default_text_$row(action_id) [template::util::richtext::create $row(default_text) $row(default_text_mime_type)]
    }

    # Save attachment_num for later
    ad_form -extend -name tasks -form \
        [list [list attachment_num_$row(action_id):integer(hidden),optional \
                   {value $row(attachment_num)}]]

    for { set i 1 } { $i <= $row(attachment_num) } { incr i } {
        if { $prop_count == "1" } {
            set missing_props_p 1
            break
        }

        ad_form -extend -name tasks -form \
            [list [list attachment_$row(action_id)_${i}:integer(select),optional \
                       {label "Attachment $i"} \
                       {options $prop_options} \
                       {help_text "Select from existing attachments or <a
href./citybuild/object-edit\">add a new prop</a> and refresh this page."}]]
    }    

    lappend actions $row(action_id)
}

if { $missing_props_p } {
    return
}

wizard submit tasks -buttons { back next }

ad_form \
    -extend \
    -name tasks \
    -form { 
        {actions:text(hidden) {value $actions}}
    } \
    -on_request {
        db_foreach attachments {
            select a.action_id,
                   m.object_id,
                   m.order_n
            from   workflow_actions a,
                   sim_task_object_map m
            where  a.workflow_id = :workflow_id
            and    m.task_id = a.action_id
            and    m.relation_tag = 'attachment'
        } {
            set attachment_${action_id}_${order_n} $object_id
        }
    } -on_submit {
        
        db_transaction {
            
            foreach action_id $actions {

                array unset row
                set row(description_mime_type) [template::util::richtext::get_property format [set description_${action_id}]]
                set row(description) [template::util::richtext::get_property contents [set description_${action_id}]]
                

		if { [exists_and_not_null default_text_${action_id}] } {
		    set row(default_text_mime_type) [template::util::richtext::get_property format [set default_text_${action_id}]]
		    set row(default_text) [template::util::richtext::get_property contents [set default_text_${action_id}]]
		}

                simulation::action::edit \
                    -action_id $action_id \
                    -workflow_id $workflow_id \
                    -array row
            
                # FIXME: The way we do this update is not very pretty: Delete all relations and re-add the new ones
                db_dml delete_all_relations {
                    delete from sim_task_object_map
                    where  task_id = :action_id
                }

                for { set i 1 } { $i <= [set attachment_num_${action_id}] } { incr i } {
                    set elm "attachment_${action_id}_$i"
                    set related_object_id [set $elm]
                    
                    if { ![empty_string_p $related_object_id] } {
                        db_dml insert_rel {
                            insert into sim_task_object_map (task_id, object_id, order_n, relation_tag)
                            values (:action_id, :related_object_id, :i, 'attachment')
                        }
                    }
                }
            }
        }
    } -after_submit {
        simulation::template::flush_inst_state -workflow_id $workflow_id
        wizard forward
    }
