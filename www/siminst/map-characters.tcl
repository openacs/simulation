ad_page_contract {
    The page for mapping roles of a simulation template
    to characters in the CityBuild world. First page
    of the mapping step.

    @author Peter Marklund
} {
    workflow_id:integer
}

# TODO: Permission check
# TODO: ability to add new character inline while mapping

set page_title "Assign Characters to Roles"
set context [list [list "." "SimInst"] $page_title]


simulation::template::get -workflow_id $workflow_id -array sim_array
set description $sim_array(description)

ad_form \
    -name characters \
    -edit_buttons { { Map ok } } \
    -form {
        {workflow_id:integer(hidden)
            {value $workflow_id}
        }
    }

set character_options [simulation::get_object_options -content_type sim_character]

# Loop over all workflow roles and add a character select widget for each
foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
    set role_pretty_name_$role_id [workflow::role::get_element -role_id $role_id -element pretty_name]

    ad_form -extend -name characters -form \
        [list [list role_${role_id}:text(select) \
                   [list label \$role_pretty_name_$role_id] \
                   [list options $character_options]

         ]]
}


wizard submit characters -buttons { back next }

ad_form -extend -name characters -on_request {
    # Less than terribly efficient
    foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
        array unset sim_role_array
        simulation::role::get -role_id $role_id -array sim_role_array
        set role_$role_id $sim_role_array(character_id)
    }
} -on_submit {
    db_transaction {
        # Map each role to chosen character
        foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
            set row(character_id) [set role_${role_id}]
            simulation::role::edit -role_id $role_id -array row
        }
    }
    
    wizard forward
}
