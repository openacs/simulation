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

set case_list [db_list_of_lists case_count {
      select distinct wc.case_id,
             wcrpm.role_id
      from workflow_cases wc,
           workflow_case_role_party_map wcrpm
     where wcrpm.party_id = :user_id
       and wc.case_id = wcrpm.case_id
}]

if { !$adminplayer_p && [llength $case_list] == 1 } {
    set case_id [lindex [lindex $case_list 0] 0]
    set role_id [lindex [lindex $case_list 0] 1]
    ad_returnredirect [export_vars -base case { case_id role_id }]
    ad_script_abort
}
