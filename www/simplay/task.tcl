ad_page_contract {
    Simplay page showing details and message form for one task.
} {
    case_id:integer
}

# TODO: fix context bar
set title "Task Information: taskname"
set context [list [list . "SimPlay"] [list [export_vars -base "case" { case_id }] "Case Name" ] $title]
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set section_uri [apm_package_url_from_id $package_id]simplay/

set adminplayer_p [permission::permission_p -object_id $package_id -privilege sim_adminplayer]
