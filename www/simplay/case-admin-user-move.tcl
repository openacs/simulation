ad_page_contract {
    Choose new roles for a user in a workflow case.

    @author Peter Marklund
} {
    case_id:integer
    user_id:integer    
}

simulation::case::get -case_id $case_id -array case
acs_user::get -user_id $user_id -array user

set page_title "Choose new roles for user $user(name)"
set context [list [list . "SimPlay"] [list [export_vars -base case-admin { case_id }] "Administer $case(label)"] $page_title]

workflow::case::get -case_id $case_id -array case

set role_options [workflow::role::get_options -id_values -workflow_id $case(workflow_id)]

ad_form \
    -name new_roles \
    -form {
        {roles:integer(checkbox),multiple
            {label "Roles"}
            {options {$role_options}}
        }
    } \
    -export { case_id user_id } \
    -on_submit {

        db_transaction {
            # Delete users old role assignments
            set old_roles [db_list select_old_roles {
                select role_id
                from workflow_case_role_party_map
                where case_id = :case_id
                  and party_id = :user_id
            }]
            foreach role_id $old_roles {
                workflow::case::role::assignee_remove \
                    -case_id $case_id \
                    -role_id $role_id \
                    -party_id $user_id
            }

            # Insert new assigned roles
            foreach role_id $roles {
                workflow::case::role::assignee_insert \
                    -case_id $case_id \
                    -role_id $role_id \
                    -party_ids [list $user_id]
            }

            # TODO: this should removed because we don't want to put the admin user
            # in when the admin is trying to swap two users
            # Assign the admin to any unassigned roles after the move
#             set unassigned_roles [db_list unassigned_roles {
#                 select wr.role_id
#                 from workflow_roles wr,
#                      workflow_cases wc
#                 where wc.case_id = :case_id
#                   and wc.workflow_id = wr.workflow_id
#                   and not exists (select 1
#                                   from workflow_case_role_party_map wcrpm
#                                   where wcrpm.case_id = :case_id
#                                     and wcrpm.role_id = wr.role_id
#                                   )
#             }]
#             foreach role_id $unassigned_roles {
#                 workflow::case::role::assignee_insert \
#                     -case_id $case_id \
#                     -role_id $role_id \
#                     -party_ids [list [ad_conn user_id]]
#             }            
        }
        
        ad_returnredirect [export_vars -base case-admin { case_id }]
    }
