ad_page_contract {
    Display and edit the task descriptions and attachments of a simulation.

    @author Peter Marklund
} {
    workflow_id:integer
}

set user_id [auth::require_login]

ad_form \
    -name tasks \
    -form { 
        {workflow_id:integer(hidden) {value $workflow_id}}
    }

set prop_options [simulation::object::get_object_type_options -object_type "sim_prop"]

set actions [list]

db_foreach tasks {
    select a.action_id,
           a.pretty_name,
           a.description,
           a.description_mime_type,
           st.attachment_num,
           (select pretty_name from workflow_roles where role_id = a.assigned_role) as assigned_role_pretty,
           (select pretty_name from workflow_roles where role_id = st.recipient) as recipient_role_pretty,
           (select count(*) from workflow_initial_action where action_id = a.action_id) as initial_p
    from   workflow_actions a,
           sim_tasks st
    where  a.workflow_id = :workflow_id
    and    st.task_id = a.action_id
    order  by a.sort_order
} -column_array row {
    if { !$row(initial_p) } {
        set section_name "Task $row(pretty_name)"
        if { ![empty_string_p $row(assigned_role_pretty)] || ![empty_string_p $row(recipient_role_pretty)] } {
            append section_name " ("
            if { ![empty_string_p $row(assigned_role_pretty)] } {
                append section_name $row(assigned_role_pretty)
            }
            if { ![empty_string_p $row(recipient_role_pretty)] } {
                append section_name "-> $row(recipient_role_pretty))"
            }
        }
        
        ad_form -extend -name tasks -form \
            [list [list description_$row(action_id):richtext,optional \
                       {label "Task Description"} \
                       {help_text "This is the text that users will see while attempting to complete a task."} \
                       {html {cols 60 rows 4}} \
                       {section $section_name} ]]
        set description_$row(action_id) [template::util::richtext::create $row(description) $row(description_mime_type)]
        
        # Save attachment_num for later
        ad_form -extend -name tasks -form \
            [list [list attachment_num_$row(action_id):integer(hidden),optional \
                       {value $row(attachment_num)}]]

        for { set i 1 } { $i <= $row(attachment_num) } { incr i } {
            ad_form -extend -name tasks -form \
                [list [list attachment_$row(action_id)_$i:integer(select),optional \
                           {label "Attachment $i"} \
                           {options $prop_options} \
                           {help_text "Select from existing attachments or <a
href=\"../citybuild/object-edit\">add a new prop</a> and refresh this page.  TODO: make this tidier - instead of this text, should be a single button which saves this form, goes to object page, and returns here."}]]
        }    

        lappend actions $row(action_id)
    }
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
                
                simulation::action::edit \
                    -action_id $action_id \
                    -workflow_id $workflow_id \
                    -array row
            
                # TODO B: The way we do this update is not very pretty: Delete all relations and re-add the new ones
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
        wizard forward
    }
