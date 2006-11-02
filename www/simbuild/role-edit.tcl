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
set user_id [ad_conn user_id]

# Get the characters to show in a dropdown list
set character_options [db_list_of_lists character_options {
    select sc.title,
           sc.item_id
    from   sim_charactersx sc,
           cr_items ci,
           acs_objects ao
    where  sc.item_id = ao.object_id
    and    ci.item_id = sc.item_id 
    and    ci.live_revision = sc.object_id
    and    (sc.in_directory_p = 't' or ao.creation_user = :user_id)
    order by sc.title
}]

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
    {character_id:text(select)
        {label "Character"}
        {options $character_options}}
} -edit_request {
    simulation::role::get -role_id $role_id -array role_array
    set workflow_id $role_array(workflow_id)

    permission::require_write_permission -object_id $workflow_id

    set pretty_name $role_array(pretty_name)
    set character_id $role_array(character_id)

    workflow::get -workflow_id $workflow_id -array sim_template_array

    set page_title "Edit Role template $pretty_name"
    set context [list [list "." "Sim Templates"] [list "template-edit?workflow_id=$workflow_id" "$sim_template_array(pretty_name)"] $page_title]    

} -cancel_url [export_vars -base "template-edit" { workflow_id }] \
-new_request {
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
    set row(character_id) $character_id
    set row(short_name) {}

    set role_id [simulation::role::edit \
                     -operation $operation \
                     -role_id $role_id \
                     -workflow_id $workflow_id \
                     -array row]

    # Let's mark this template edited
    set sim_type "dev_template"

    ad_returnredirect -message [_ simulation.role_updated] [export_vars -base "template-sim-type-update" { workflow_id sim_type }]
    ad_script_abort
}

# maybe replace this chunk of copied text with an includable template
# which passes in a filter for the workflow_id?
