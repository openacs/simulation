ad_page_contract {
    Add/edit role.

    @creation-date 2003-10-27
    @cvs-id $Id$
} {
    workflow_id:optional
    role_id:optional
} -validate {
    workflow_id_or_role_id {
        if { ![exists_and_not_null workflow_id] &&
             ![exists_and_not_null role_id]} {
            ad_complain "Either role_id or workflow_id is required."
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

######################################################################
#
# role
#
# a form showing fields for a role in a workflow
# includes add and edit modes and handles form submission
# display mode is only in list form via sim-template-edit
#
######################################################################

#---------------------------------------------------------------------
# role form
#---------------------------------------------------------------------

ad_form -name role -cancel_url sim-template-list -form {
    {role_id:key}
    {workflow_id:integer(hidden),optional}
    {name:text
        {label "Role Name"}
        {html {size 20}}
    }
} -edit_request {
    workflow::role::get -role_id $role_id -array role_array
    set workflow_id $role_array(workflow_id)
    set name $role_array(pretty_name)
    workflow::get -workflow_id $workflow_id -array sim_template_array    
    set page_title "Edit Role template $name"
    set context [list [list "sim-template-list" "Sim Templates"] [list "sim-template-edit?workflow_id=$workflow_id" "$sim_template_array(pretty_name)"] $page_title]    
} -new_request {
    workflow::get -workflow_id $workflow_id -array sim_template_array
    set page_title "Add Role to $sim_template_array(pretty_name)"
    set context [list [list "sim-template-list" "Sim Templates"] [list "sim-template-edit?workflow_id=$workflow_id" "$sim_template_array(pretty_name)"] $page_title]
} -new_data {

    simulation::role::new \
        -template_id $workflow_id \
        -role_short_name $name \
        -role_pretty_name $name

} -after_submit {
    ad_returnredirect [export_vars -base "sim-template-edit" { workflow_id }]
    ad_script_abort
}

# maybe replace this chunk of copied text with an includable template
# which passes in a filter for the workflow_id?
