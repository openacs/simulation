ad_page_contract {
    List the users who are playing a certain role in a simulation case.

    @author Peter Marklund
} {
    case_id:integer
    role_id:integer
}

simulation::case::get -case_id $case_id -array case
workflow::role::get -role_id $role_id -array role
workflow::get -workflow_id $case(workflow_id) -array workflow

set page_title [_ simulation.lt_Users_playing_role_ro]
set cast_url [export_vars -base cast { {workflow_id $case(workflow_id)} }]
set context [list [list "." [_ simulation.SimPlay]]
                  [list $cast_url
                    [_ simulation.lt_Join_a_Case_in_Simula]]
                  $page_title]

template::list::create \
    -name users \
    -multirow users \
    -no_data [_ simulation.lt_There_are_no_users_pl] \
    -elements {
        user_link {
            label {[_ simulation.User]}
            display_template {
                @users.user_link;noquote@
            }
        }
    }

db_multirow -extend { user_link } users users {
    select cu.user_id,
           cu.first_names || ' ' || cu.last_name as user_name
    from cc_users cu,
         workflow_case_role_party_map wcrpm
    where wcrpm.case_id = :case_id
      and wcrpm.role_id = :role_id
      and wcrpm.party_id = cu.user_id
} {
    set user_link [acs_community_member_link -user_id $user_id -label $user_name]
}
