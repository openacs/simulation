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
    {name:text,optional
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
    {description:text(textarea),optional
        {label "TODO: Description and<br> Description-mime-type"}
        {html {cols 60 rows 8}}
    }
} -edit_request {

    permission::require_write_permission -object_id $workflow_id
    simulation::template::get -workflow_id $workflow_id -array sim_template_array
    set name $sim_template_array(pretty_name)

    # translate sim_type to ready/not-ready
    # TODO: we should only see ready_template and dev_template here, so maybe assert that?
    if {$sim_template_array(sim_type) == "ready_template"} {
        set template_ready_p "t"
    } else {
        set template_ready_p "f"
    }

    set suggested_duration $sim_template_array(suggested_duration)

} -new_request {

    permission::require_permission -object_id $package_id -privilege sim_template_create

} -new_data {

    permission::require_permission -object_id $package_id -privilege sim_template_create
    set workflow_id [simulation::template::new \
                         -short_name $name \
                         -pretty_name $name \
                         -suggested_duration $suggested_duration \
                         -package_key $package_key \
                         -object_id $package_id]
    
} -edit_data {

    if {$template_ready_p == "t"} {
        set sim_type "ready_template"
    } else {
        set sim_type "dev_template"
    }

    permission::require_write_permission -object_id $workflow_id
    simulation::template::edit \
        -workflow_id $workflow_id \
        -short_name $name \
        -pretty_name $name \
        -sim_type $sim_type \
        -suggested_duration $suggested_duration \
        -package_key $package_key \
        -object_id $package_id

} -after_submit {

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
        set page_title "Editing $name"
    }
}

set context [list [list "." "SimBuild"] $page_title] 

set delete_url [export_vars -base template-delete { workflow_id }]

set spec_url [export_vars -base template-spec { workflow_id }]

