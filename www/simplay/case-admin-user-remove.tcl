ad_page_contract {
    Remove a user from role in a workflow case. If this makes the role the
    user was playing not mapped to any users it will be mapped to the admin
    removing the user.

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

ad_returnredirect [export_vars -base case-admin { case_id }]
