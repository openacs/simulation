ad_page_contract {
    Delete a case.
} {
    case_id:integer
    {return_url "."}
    {confirm_p:boolean 0}
}


permission::require_permission -object_id [ad_conn package_id] -privilege sim_adminplayer

simulation::case::get -case_id $case_id -array case

if { [template::util::is_true $confirm_p] } {
    workflow::case::delete -case_id $case_id
    ad_returnredirect -message "Case \"$case(label)\" has been deleted." "."
    ad_script_abort
}

set page_title "Delete case \"$case(label)\""
set context [list [list "." "SimPlay"] $page_title]

set delete_url [export_vars -base [ad_conn url] { case_id return_url { confirm_p 1 } }]
set cancel_url $return_url
