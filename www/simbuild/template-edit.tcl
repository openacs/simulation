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
} else {
    set mode display
}

ad_form -name sim_template -mode $mode -cancel_url . -form {
    {workflow_id:key}
    {name:text,optional
        {label "Template Name"}
        {html {size 40}}
    }
    {ready_p:boolean(checkbox),optional
        {label "Ready for use?"}
        {options {{"Ready for use" t}}}
    }
    {suggested_duration:text,optional
        {label "Suggested Duration"}
    }
} -edit_request {
    simulation::template::get -workflow_id $workflow_id -array sim_template_array
    set name $sim_template_array(pretty_name)
    set ready_p $sim_template_array(ready_p)
    set suggested_duration $sim_template_array(suggested_duration)
} -new_data {
    set workflow_id [simulation::template::new \
                         -short_name $name \
                         -pretty_name $name \
                         -ready_p $ready_p \
                         -suggested_duration $suggested_duration \
                         -package_key $package_key \
                         -object_id $package_id]
} -edit_data {
    simulation::template::edit \
        -workflow_id $workflow_id \
        -short_name $name \
        -pretty_name $name \
        -ready_p $ready_p \
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
