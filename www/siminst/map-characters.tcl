ad_page_contract {
    The page for mapping roles of a simulation template
    to characters in the CityBuild world. First page
    of the mapping step.

    @author Peter Marklund
} {
    workflow_id:integer
}

set user_id [ad_conn user_id]
permission::require_write_permission -object_id $workflow_id

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

# Only show characters in the yellow pages and characters that admin has created
# himself
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

# Loop over all workflow roles and add a character select widget for each
foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
    set role_pretty_name_$role_id [workflow::role::get_element -role_id $role_id -element pretty_name]

    ad_form -extend -name characters -form \
        [list [list role_${role_id}:text(select) \
                   [list label \$role_pretty_name_$role_id] \
                   [list options $character_options]

         ]]
}

ad_form -extend -name characters -form {
  {show_contacts_p:boolean(radio),optional
    {label "Should we show these contacts?"}
    {options {{"Show contacts" t} {"Don't show contacts" f}}}
  }
}

wizard submit characters -buttons { back next }

ad_form -extend -name characters -on_request {
    # Less than terribly efficient
    foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
        array unset sim_role_array
        simulation::role::get -role_id $role_id -array sim_role_array
        set role_$role_id $sim_role_array(character_id)
    }
    set show_contacts_p [db_string gettheflag {
      select show_contacts_p
        from sim_simulations
       where simulation_id=:workflow_id}]
} -on_submit {
    db_transaction {
        # Map each role to chosen character
        foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
            set row(character_id) [set role_${role_id}]
            simulation::role::edit -role_id $role_id -array row
        }
        db_dml show_contacts_p {
          update sim_simulations
             set show_contacts_p = :show_contacts_p
             where simulation_id = :workflow_id
        }
    }

    simulation::template::flush_inst_state -workflow_id $workflow_id
    wizard forward
}
