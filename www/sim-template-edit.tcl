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

ad_form -name sim_template -cancel_url sim-template-list -form {
    {workflow_id:key}
    {name:text,optional
        {label "Template Name"}
        {html {size 40}}
    }
} -edit_request {
    workflow::get -workflow_id $workflow_id -array sim_template_array
    set name $sim_template_array(pretty_name)
    set page_title "Edit template $name"
    set context [list [list "sim-template-list" "Templates"] $page_title]
} -new_request {
    set page_title "Create template"
    set context [list [list "sim-template-list" "Templates"] $page_title]
} -new_data {
    set workflow_id [workflow::new \
                         -short_name $name \
                         -pretty_name $name \
                     -package_key $package_key]
    # create a dummy action with initial action setting because
    # workflow::get doesn't work on bare workflows
    workflow::action::fsm::new -initial_action_p t -workflow_id $workflow_id \
                         -short_name "dummy action" \
                         -pretty_name "dummy action"
} -after_submit {
    ad_returnredirect sim-template-edit?workflow_id=$workflow_id
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

set context [list [list "sim-template-list" "Sim Templates"] $page_title] 


