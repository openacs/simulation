ad_page_contract {
    Offers a selection of users for an admin to add to a role in a simulation case.

    @author Peter Marklund
} {
    case_id:integer
    role_id:integer
}

simulation::case::get -case_id $case_id -array case
set simulation_id $case(workflow_id)

workflow::role::get -role_id $role_id -array role

set page_title "Choose new users for role $role(pretty_name)"
set context [list [list . "SimPlay"] [list [export_vars -base case-admin { case_id }] "Administer $case(label)"] $page_title]

set user_options [db_list_of_lists user_options_for_case {
    select cu.first_names || ' ' || cu.last_name,
           cu.user_id
    from cc_users cu,
         sim_party_sim_map spsm
    where spsm.party_Id = cu.user_id
      and spsm.type = 'enrolled'
      and spsm.simulation_id = :simulation_id
}]

ad_form \
    -name new_user \
    -form {
        {users:integer(checkbox),multiple
            {label "New Users"}
            {options {$user_options}}
        }
    } \
    -export { case_id role_id } \
    -on_submit {

        workflow::case::role::assignee_insert \
            -case_id $case_id \
            -role_id $role_id \
            -party_ids $users
        
        ad_returnredirect [export_vars -base case-admin { case_id }]        
    }
