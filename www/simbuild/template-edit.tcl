ad_page_contract {
    Add/edit template.

    @creation-date 2003-10-13
    @cvs-id $Id$
} {
    workflow_id:optional
}

set package_key [ad_conn package_key]
set package_id [ad_conn package_id]

######################################################################
#
# sim_template
#
# a form showing fields for a sim template
# includes add, edit, and display modes and handles form submission
#
# TODO: display mode doesn't exist yet - all display is through edit mode
#
######################################################################

#---------------------------------------------------------------------
# sim_template form
#---------------------------------------------------------------------

if { [ad_form_new_p -key workflow_id] } {
    set mode edit
    set cancel_url .
} else {
    set mode display
    set cancel_url [export_vars -base [ad_conn url] { workflow_id }]
}

ad_form -name sim_template -mode $mode -cancel_url $cancel_url -form {
    {workflow_id:key}
    {pretty_name:text,optional
        {label "Template Name"}
        {html {size 40}}
    }
}

if { ![ad_form_new_p -key workflow_id] } {
    ad_form -extend -name sim_template -form {
        {template_ready_p:boolean(checkbox),optional
            {label "Ready for use?"}
            {options {{"Yes" t}}}
        }
    }
} else {
    ad_form -extend -name sim_template -form {
        {template_ready_p:boolean(hidden),optional
            {value f}
        }
    }
}

ad_form -extend -name sim_template -form {
    {suggested_duration:text,optional
        {label "Suggested Duration"}
    }
    {description:richtext(richtext),optional
        {label "Description"}
        {html {cols 60 rows 8}}
    }
} -edit_request {

    permission::require_write_permission -object_id $workflow_id

    simulation::template::get -workflow_id $workflow_id -array sim_template_array

    set pretty_name $sim_template_array(pretty_name)

    set description [template::util::richtext::create $sim_template_array(description) $sim_template_array(description_mime_type)]

    # translate sim_type to ready/not-ready
    
    if { [lsearch { dev_template ready_template } $sim_template_array(sim_type)] == -1 } {
        error "Can only handle dev_template and ready_template sim_types here."
    }

    set template_ready_p [db_boolean [string equal $sim_template_array(sim_type) "ready_template"]]

    set suggested_duration $sim_template_array(suggested_duration)
    if {$template_ready_p} {
        set inst_url [export_vars -base "../siminst/map-create" { workflow_id }]
    }
} -new_request {

    permission::require_permission -object_id $package_id -privilege sim_template_create
    
} -on_submit {
    set description_mime_type [template::util::richtext::get_property format $description]
    set description [template::util::richtext::get_property contents $description]
} -new_data {

    permission::require_permission -object_id $package_id -privilege sim_template_create
    set operation "insert"

    set row(package_key) $package_key 
    set row(object_id) $package_id
    set row(sim_type) "dev_template"
    
} -edit_data {

    if { [template::util::is_true $template_ready_p] } {
        set row(sim_type) "ready_template"
    } else {
        set row(sim_type) "dev_template"
    }

    permission::require_write_permission -object_id $workflow_id
    set operation "update"

} -after_submit {

    set row(short_name) {}
    foreach elm { pretty_name suggested_duration description description_mime_type } {
        set row($elm) [set $elm]
    }

    set workflow_id [simulation::template::edit \
                         -operation $operation \
                         -workflow_id $workflow_id \
                         -array row]

    ad_returnredirect [export_vars -base "template-edit" { workflow_id }]
    ad_script_abort

}

#---------------------------------------------------------------------
# Determine if we are in edit mode or display mode
#---------------------------------------------------------------------
# this is prototype code to correct for get_action's apparent
# unreliability

set mode [template::form::get_action sim_template]
if { ![exists_and_not_null workflow_id]} {
    set mode "add"
} else {
    # for now, use edit mode in place of display mode
    #    set mode "display"
    set mode "edit"
}

switch $mode {
    add {
        set page_title "New Simulation Template"
    }
    edit {
        set page_title "Editing $pretty_name"
    }
}

set context [list [list "." "SimBuild"] $page_title] 

set delete_url [export_vars -base template-delete { workflow_id }]

set spec_url [export_vars -base template-spec { workflow_id }]

