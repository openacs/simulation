ad_page_contract {
    The page where actors are chosen for the different
    roles of a simulation. Part of the casting step
    in the instantiation process.

    @author Peter Marklund
} {
    workflow_id:integer
}

set page_title "Choose actors"
set context [list [list "." "SimInst"] $page_title]

# Loop over all workflow roles and append the actor and "in groups of" widgets to the form
set form {
        {pretty_name:text
            {label "Simulation name"}
            {html {size 50}}
        }
}

foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
    set role_pretty_name [workflow::role::get_element -role_id $role_id -element pretty_name]
    lappend form [list actor_${role_id}:text(select) \
                      [list label $role_pretty_name] \
                      [list options {{Student student} {Professor professor}}]
                 ]
    lappend form [list group_${role_id}:integer [list label "In groups of"] [list value 1]]
}

ad_form \
    -name actors \
    -export { workflow_id } \
    -form $form \
    -on_submit {

        # Put the actor and grouping selections on array list formats
        set actors_list [list]
        set groups_list [list]
        foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
            lappend actors_list $role_id [set actor_$role_id]
            lappend groups_list $role_id [set group_$role_id]
        }

        simulation::cast \
            -workflow_id $workflow_id \
            -pretty_name $pretty_name \
            -actors $actors_list \
            -groups $groups_list

        # Proceed to the instantiation complete page
        ad_returnredirect [export_vars -base cast-complete {workflow_id}]
        ad_script_abort
    }