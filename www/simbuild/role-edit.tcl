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
# display mode is only in list form via template-edit
#
######################################################################

#---------------------------------------------------------------------
# role form
#---------------------------------------------------------------------

ad_form -name role -form {
    {role_id:key}
    {workflow_id:integer(hidden),optional}
    {pretty_name:text
        {label "Role Name"}
        {html {size 20}}
    }
} -edit_request {
    simulation::role::get -role_id $role_id -array role_array
    set workflow_id $role_array(workflow_id)

    permission::require_write_permission -object_id $workflow_id

    set pretty_name $role_array(pretty_name)

    workflow::get -workflow_id $workflow_id -array sim_template_array

    set page_title "Edit Role template $pretty_name"
    set context [list [list "." "Sim Templates"] [list "template-edit?workflow_id=$workflow_id" "$sim_template_array(pretty_name)"] $page_title]    

} -new_request {
    permission::require_write_permission -object_id $workflow_id
    workflow::get -workflow_id $workflow_id -array sim_template_array
    set page_title "Add Role to $sim_template_array(pretty_name)"
    set context [list [list "." "Sim Templates"] [list "template-edit?workflow_id=$workflow_id" "$sim_template_array(pretty_name)"] $page_title]

} -new_data {
    permission::require_write_permission -object_id $workflow_id
    set operation "insert"

} -edit_data {
    # We use role_array(workflow_id) here, which is gotten from the DB, and not
    # workflow_id, which is gotten from the form, because the workflow_id from the form 
    # could be spoofed
    workflow::role::get -role_id $role_id -array role_array
    set workflow_id $role_array(workflow_id)
    permission::require_write_permission -object_id $workflow_id
    set operation "update"
} -after_submit {

    set row(pretty_name) $pretty_name
    set row(short_name) {}

    set role_id [simulation::role::edit \
                     -operation $operation \
                     -role_id $role_id \
                     -workflow_id $workflow_id \
                     -array row]

    ad_returnredirect [export_vars -base "template-edit" { workflow_id }]
    ad_script_abort
}

# maybe replace this chunk of copied text with an includable template
# which passes in a filter for the workflow_id?
