ad_page_contract {
    The page for mapping roles of a simulation template
    to characters in the CityBuild world. First page
    of the mapping step.

    @author Peter Marklund
} {
    workflow_id:integer
}

set page_title "Map to Characters"
set context [list [list "." "SimInst"] $page_title]

# Loop over all workflow roles and add a character select widget for each
# set form [list]
# set character_options [simulation::get_object_options -content_type sim_character]
# foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
#     lappend form [list role_${role_id}:text(select) \
#                       [list label [workflow::get_element -role_id $role_id -element pretty_name]] \
#                       [list options $character_options]
#                  ]
# }

# ad_form -name characters -form $form
