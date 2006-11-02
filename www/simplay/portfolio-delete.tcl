ad_page_contract {
    Delete a message.
} {
    document_id:integer
    case_id:integer
    role_id:integer
    {undelete_p 0}
    {return_url ""}
}

simulation::case::assert_user_may_play_role \
  -case_id $case_id -role_id $role_id

if { $undelete_p } {
  db_dml pf_undelete "delete from sim_portfolio_trash
                      where object_id = :document_id and
                      case_id = :case_id and
                      role_id = :role_id"
} else {
  db_dml pf_delete "insert into sim_portfolio_trash (object_id, role_id, case_id) values (:document_id, :role_id, :case_id)"
}

set package_id [ad_conn package_id]
if {[empty_string_p $return_url]} {
  set return_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/portfolio" { case_id role_id }]
}

ad_returnredirect -message [ad_decode $undelete_p 0 [_ simulation.document_moved_to_trash] [_ simulation.document_undeleted]] $return_url
ad_script_abort