ad_page_contract {
    Add/edit FSM state.

    @creation-date 2003-12-09
    @cvs-id $Id$
} {
    {workflow_id:integer ""}
    state_id:integer,optional
} -validate {
    workflow_id_or_state_id {
        if { ![exists_and_not_null workflow_id] &&
             ![exists_and_not_null state_id]} {
            ad_complain "Either state_id or workflow_id is required."
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

if { ![ad_form_new_p -key state_id] } {
    workflow::state::fsm::get -state_id $state_id -array state_array
    set workflow_id $state_array(workflow_id)
}

workflow::get -workflow_id $workflow_id -array sim_template_array

if { ![ad_form_new_p -key state_id] } {
    set page_title "Edit State $state_array(pretty_name)"
} else {

    set page_title "Add State to $sim_template_array(pretty_name)"
}
set context [list [list "." "SimBuild"] [list [export_vars -base "template-edit" { workflow_id }] "$sim_template_array(pretty_name)"] $page_title]

#---------------------------------------------------------------------
# Get a list of relevant roles
#---------------------------------------------------------------------
set role_options [workflow::role::get_options -workflow_id $workflow_id]

######################################################################
#
# state
#
# a form showing fields for a state in a workflow
# includes add and edit modes and handles form submission
# display mode is only in list form via template-edit
#
######################################################################

#---------------------------------------------------------------------
# state form
#---------------------------------------------------------------------

ad_form -name state -edit_buttons [list [list [ad_decode [ad_form_new_p -key state_id] 1 [_ acs-kernel.common_add] [_ acs-kernel.common_edit]] ok]] -form {
    {state_id:key}
    {workflow_id:integer(hidden)
        {value $workflow_id}
    }
    {pretty_name:text
        {label "State Name"}
        {html {size 20}}
        {help_text "Each simulation can be in only one state at a time.  The list of available tasks can be different in each state."}
    }
} -edit_request {
    set workflow_id $state_array(workflow_id)
    permission::require_write_permission -object_id $workflow_id
    set pretty_name $state_array(pretty_name)
} -new_request {
    permission::require_write_permission -object_id $workflow_id
} -new_data {
    permission::require_write_permission -object_id $workflow_id

    set operation "insert"
} -edit_data {
    # We use state_array(workflow_id) here, which is gotten from the DB, and not
    # workflow_id, which is gotten from the form, because the workflow_id from the form 
    # could be spoofed
    set workflow_id $state_array(workflow_id)
    permission::require_write_permission -object_id $workflow_id
    set operation "update"
} -after_submit {
    set row(pretty_name) $pretty_name
    set row(short_name) {}

    set state_id [workflow::state::fsm::edit \
                      -operation $operation \
                      -state_id $state_id \
                      -workflow_id $workflow_id \
                      -array row]

    ad_returnredirect [export_vars -base "template-edit" { workflow_id }]
    ad_script_abort
}
