ad_page_contract {
    Delete a case.
} {
    case_id:integer
    {return_url "."}
    {confirm_p:boolean 0}
}


permission::require_permission -object_id [ad_conn package_id] \
  -privilege sim_adminplayer

simulation::case::get -case_id $case_id -array case

if { [template::util::is_true $confirm_p] } {
    workflow::case::delete -case_id $case_id
    ad_returnredirect -message [_ simulation.lt_Case_caselabel_has_be] "."
    ad_script_abort
}

set page_title [_ simulation.lt_Delete_case_caselabel]
set context [list [list "." [_ simulation.SimPlay]] $page_title]

set delete_url [export_vars -base [ad_conn url] \
                 { case_id return_url { confirm_p 1 } }]
set cancel_url $return_url
