ad_page_contract {
    Add/edit task.

    @creation-date 2003-10-27
    @cvs-id $Id$
} {
    {workflow_id:integer ""}
    action_id:optional
    parent_action_id:integer,optional
    return_url:optional
} -validate {
    workflow_id_or_task_id {
        if { ![exists_and_not_null workflow_id] &&
             ![exists_and_not_null action_id]} {
            ad_complain "Either task_id or workflow_id is required."
        }
    }
}

######################################################################
#
# preparation
#
######################################################################

set package_key [ad_conn package_key]
set package_id [ad_conn package_id]

set num_sub_actions 0

if { ![ad_form_new_p -key action_id] } {
    simulation::action::get -action_id $action_id -array task_array
    
    set workflow_id $task_array(workflow_id)

    # Message tasks have a recipient; upload document tasks ("normal") have no recipient
    if { ![empty_string_p $task_array(recipient_roles)] } {
        set task_type "message"
    } else {
        set task_type "normal"
    }
    
    set trigger_type $task_array(trigger_type)
    set parent_action_id $task_array(parent_action_id)

    if { [lsearch -exact { workflow parallel dynamic } $trigger_type] != -1 } {
        set num_sub_actions [db_string num_sub_actions { 
            select count(*) 
            from   workflow_actions 
            where  parent_action_id = :action_id
        }]
    }
}

set prop_options [simulation::object::get_object_type_options -object_type "sim_prop" -null_label "--Not Yet Selected--"]

set prop_count [llength $prop_options]

workflow::get -workflow_id $workflow_id -array sim_template_array

if { ![ad_form_new_p -key action_id] } {
    set page_title "Edit Task $task_array(pretty_name)"
    set attachment_count [db_string att_count {select count(*) + 5 from sim_task_object_map
                                               where  task_id = :action_id}]
} else {
    set attachment_count 5
    set page_title "Add Task to $sim_template_array(pretty_name)"
}

if { ![exists_and_not_null return_url] } {
        set return_url [export_vars -base "template-edit" -anchor "tasks" { workflow_id }] 
} 

set context [list [list "." "SimBuild"] [list [export_vars -base "template-edit" { workflow_id }] "$sim_template_array(pretty_name)"] $page_title]

#---------------------------------------------------------------------
# Get a list of relevant roles
#---------------------------------------------------------------------
set role_options [workflow::role::get_options -workflow_id $workflow_id]
set role_options_with_null [concat [list [list "--None--" ""]] $role_options]

#---------------------------------------------------------------------
# Logic to determine the current values of a few elements
#---------------------------------------------------------------------

if { ![empty_string_p [ns_queryget trigger_type]] } {
    set trigger_type [ns_queryget trigger_type]
} elseif { ![exists_and_not_null trigger_type] && [ad_form_new_p -key action_id] } {
    set trigger_type "user"
}
if { ![empty_string_p [ns_queryget task_type]] } {
    set task_type [ns_queryget task_type]
} elseif { ![exists_and_not_null task_type] && [ad_form_new_p -key action_id] } {
    set task_type "message"
}

######################################################################
#
# task
#
# a form showing fields for a task in a workflow
# includes add and edit modes and handles form submission
# display mode is only in list form via template-edit
#
######################################################################

#---------------------------------------------------------------------
# task form
#---------------------------------------------------------------------

ad_form \
    -name task \
    -export { workflow_id return_url } \
    -cancel_url $return_url \
    -edit_buttons [list \
                       [list \
                            [ad_decode [ad_form_new_p -key action_id] 1 [_ acs-kernel.common_OK] [_ acs-kernel.common_OK]] \
                            ok]] \
    -form {
        {action_id:key}
    }

if { [exists_and_not_null parent_action_id] } {
    simulation::action::get -action_id $parent_action_id -array parent_task_array
    ad_form -extend -name task -form {
        {parent_action_id:integer(select)
            {label "Parent task"}
            {mode display}
            {options {[workflow::action::get_options -all=1 -workflow_id $workflow_id]}}
        }
    }
} else {
    ad_form -extend -name task -form {
        {parent_action_id:integer(hidden),optional {value {}}}
    }
}

ad_form -extend -name task -form {
    {pretty_name:text
        {label "Task Name"}
        {html {size 50}}
    }
    {trigger_type:text(radio)
        {label {[ad_decode $num_sub_actions 0 "Trigger Type" "Trigger Type<br>(Cannot edit because<br>task has child tasks)"]}}
        {mode {[ad_decode $num_sub_actions 0 "" "display"]}}
        {options { 
            { "User task" user } 
            { "Automatic timer" time } 
            { "Initial action" init } 
            { "Workflow" workflow } 
            { "Parallel" parallel } 
        }}
        {html {onChange "javascript:acs_FormRefresh('task');"}}
    }
}



if { [string equal $trigger_type "user"] } {
    ad_form -extend -name task -form {
        {task_type:text(radio)
            {label "Task is complete when"}
            {options { 
                { "Assignee sends message to recipient" message }
                { "Assignee adds document to portfolio" normal } 
            }}
            {html {onChange "javascript:acs_FormRefresh('task');"}}
        }
        {assigned_role:text(select),optional
            {label "Assignee"}
            {options $role_options_with_null}
        }
    }
} else {
    ad_form -extend -name task -form { 
        {task_type:text(hidden)} 
        {assigned_role:text(hidden),optional}
    }
}

if { [string equal $trigger_type "user"] && [string equal $task_type "message"] } {
    ad_form -extend -name task -form {
        {recipient_roles:text(checkbox),optional,multiple
            {label "Recipients"}
            {options $role_options}
        }
    }
} else {
    ad_form -extend -name task -form { 
        {recipient_roles:text(hidden),optional}
    }
}


switch $trigger_type {
    user - message - workflow - parallel - dynamic - time  {
        ad_form -extend -name task -form { 
            {timeout_hours:float(text),optional
                {label "Timeout"}
                {after_html "hours"}
                {help_text "[_ simulation.lt_Duration_in_hours_dec]"}
            }
        }
    }
    default {
        ad_form -extend -name task -form { 
            {timeout_hours:float(hidden),optional}
        }
    }
}

switch $trigger_type {
    init {
    }
    default {
        ad_form -extend -name task -form {
            {description:richtext,optional
                {label "Task Description"}
                {html {cols 60 rows 8}}
                {help_text "Suggested text; can be edited when template is instantiated."}
            }
        }
    }
}

if { [string equal $trigger_type "user"] && [string equal $task_type "message"] } {
    ad_form -extend -name task -form {
	{default_text:richtext,optional
	    {label "Default Message"}
	    {html {cols 60 rows 8}}
	    {help_text "Suggested message; can be edited when template is instantiated."}
	}	
    }
}

if { [string equal $trigger_type "user"] } {    
    if { ![ad_form_new_p -key action_id] } {
    
      db_foreach attachments {
          select a.action_id,
                 m.object_id,
                 m.order_n
          from   workflow_actions a,
                 sim_task_object_map m
          where  a.action_id = :action_id
          and    m.task_id = a.action_id
          and    m.relation_tag = 'attachment'
      } {
          set attachment_${order_n} $object_id
      }
    }
    for { set i 1 } { $i <= [set attachment_count] } { incr i } {
      set help_text [ad_decode $i 1 "Select from existing attachments or <a
href./citybuild/object-edit\">add a new prop</a> and refresh this page." \
                                 5 "You can add more attachments by saving the task and returning to this form." \
                                 ""]
                            
        ad_form -extend -name task -form \
            [list [list attachment_${i}:integer(select),optional \
                       {label "Attachment $i"} \
                       {options $prop_options} \
                       {help_text $help_text}]]
    }
}

set enabled_options [list]
set state_options [list]
lappend state_options [list "--Unchanged--" {}]
foreach state_id [workflow::fsm::get_states -workflow_id $workflow_id -parent_action_id $parent_action_id] {
    array unset state_array
    workflow::state::fsm::get -state_id $state_id -array state_array
    lappend enabled_options [list $state_array(pretty_name) $state_id]
    lappend state_options [list $state_array(pretty_name) $state_id]
}

if { [exists_and_equal parent_task_array(trigger_type) "parallel"] || [exists_and_equal parent_task_array(trigger_type) "dynamic"] } {
    ad_form -extend -name task -form {
        {new_state_id:integer(hidden),optional}
    }
} else {
    ad_form -extend -name task -form {
        {new_state_id:integer(select),optional
            {label "Next state"}
            {options $state_options}
            {help_text "After this task is completed, change the template's state."}
        }
    }
}

set focus "task.pretty_name"

ad_form -extend -name task -edit_request {
    set workflow_id $task_array(workflow_id)
    permission::require_write_permission -object_id $workflow_id

    set description [template::util::richtext::create $task_array(description) $task_array(description_mime_type)]
    set default_text [template::util::richtext::create $task_array(default_text) $task_array(default_text_mime_type)]

    foreach elm { 
        pretty_name new_state_id 
        assigned_role recipient_roles
        trigger_type parent_action_id
    } {
        set $elm $task_array($elm)
    }

    set timeout_hours ""
    if { ![empty_string_p $task_array(timeout_seconds)] } {
        set timeout_hours [expr $task_array(timeout_seconds) / 3600.0]
    }

} -new_request {
    permission::require_write_permission -object_id $workflow_id

    set trigger_type "user"
    set task_type "message"
} -on_refresh {    
    set focus {}
} -on_submit {

    if { [string equal $trigger_type "parallel"] } {
        unset assigned_role
    }

    # Check that pretty_name is unique
    set unique_p [workflow::action::pretty_name_unique_p \
                      -workflow_id $workflow_id \
                      -parent_action_id $parent_action_id \
                      -action_id $action_id \
                      -pretty_name $pretty_name]
    
    if { !$unique_p } {
        form set_error task pretty_name "This name is already used by another task"
        break
    }

    if { [info exists description] } {
        set description_mime_type [template::util::richtext::get_property format $description]
        set description [template::util::richtext::get_property contents $description]
    }

    if { [info exists default_text] } {
        set default_text_mime_type [template::util::richtext::get_property format $default_text]
        set default_text [template::util::richtext::get_property contents $default_text]
    }

    switch $task_type {
        message {
        }
        normal {
            set recipient_roles {}
        }
    }

    set pretty_past_tense $pretty_name

    foreach elm { 
        pretty_name pretty_past_tense assigned_role description description_mime_type
        new_state_id default_text default_text_mime_type
        recipient_roles attachment_num trigger_type parent_action_id
    } {
        if { [info exists $elm] } {
            set row($elm) [set $elm]
        }
    }
    set row(timeout_seconds) ""
    if { ![empty_string_p $timeout_hours] } {
        set row(timeout_seconds) [expr $timeout_hours * 3600]
    }
    set row(short_name) {}

} -new_data {
    permission::require_write_permission -object_id $workflow_id
    set operation "insert"

} -edit_data {
    # We use task_array(workflow_id) here, which is gotten from the DB, and not
    # workflow_id, which is gotten from the form, because the workflow_id from the form 
    # could be spoofed
    set workflow_id $task_array(workflow_id)

    permission::require_write_permission -object_id $workflow_id

    set operation "update"

} -after_submit {
    
    db_transaction {
      set action_id [simulation::action::edit \
                         -operation $operation \
                         -workflow_id $workflow_id \
                         -action_id $action_id \
                         -array row]

      if { [string equal $trigger_type "user"] } {

        db_dml delete_all_relations {
           delete from sim_task_object_map
           where  task_id = :action_id
        }

        for { set i 1 } { $i <= [set attachment_count] } { incr i } {
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
    }
    


    # Let's mark this template edited
    set sim_type "dev_template"
    
    ad_returnredirect [export_vars -base "template-sim-type-update" { workflow_id sim_type return_url }]

    ad_script_abort
}
