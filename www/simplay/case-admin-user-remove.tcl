ad_page_contract {
    Remove a user from role in a workflow case. If this makes the role the user was playing
    not mapped to any users it will be mapped to the admin removing the user.

    @author Peter Marklund
} {
    case_id:integer
    user_id:integer
    role_id:integer
}

# Remove the user
workflow::case::role::assignee_remove \
    -case_id $case_id \
    -role_id $role_id \
    -party_id $user_id

# TODO: this should removed because we don't want to put the admin user
# in when the admin is trying to swap two users
# # Assign the admin if the role is now unmapped
# set remaining_assignees [workflow::case::role:get_assignees \
#                              -case_id $case_id \
#                              -role_id $role_id]
# if { [llength $remaining_assignees] == 0 } {
#     workflow::case::role::assignee_insert \
#         -case_id $case_id \
#         -role_id $role_id \
#         -party_ids [list [ad_conn user_id]]
# }

ad_returnredirect [export_vars -base case-admin { case_id }]
