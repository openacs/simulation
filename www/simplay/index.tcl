ad_page_contract {
    Simplay index page.
} {
    {case_id:integer ""}
}

set title "SimPlay"
set context [list $title]
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set section_uri [apm_package_url_from_id $package_id]simplay/

set adminplayer_p [permission::permission_p -object_id $package_id -privilege sim_adminplayer]
