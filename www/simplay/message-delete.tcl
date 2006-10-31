ad_page_contract {
    Delete a message.
} {
    message_id:integer
    case_id:integer
    role_id:integer
    {undelete_p ""}
    {return_url ""}
}

simulation::case::assert_user_may_play_role \
  -case_id $case_id -role_id $role_id

if {[empty_string_p $undelete_p]} {
  simulation::message::delete -message_id $message_id -role_id $role_id -case_id $case_id
} else {
  simulation::message::undelete -message_id $message_id -role_id $role_id -case_id $case_id
}

set package_id [ad_conn package_id]
if {[empty_string_p $return_url]} {
  set return_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/messages" { item_id case_id role_id }]
}

ad_returnredirect -message [ad_decode $undelete_p "" [_ simulation.message_moved_to_trash] [_ simulation.message_undeleted]] $return_url
ad_script_abort