# an includelet showing messages and tasks for a user

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set section_uri [apm_package_url_from_id $package_id]simplay/
set adminplayer_p [permission::permission_p -object_id $package_id -privilege sim_adminplayer]

if { ![info exists case_id] } {
    set case_id {}
    set workflow_id {}
} else {
    set workflow_id [simulation::case::get_element -case_id $case_id -element workflow_id]    
}

if { !$adminplayer_p } {
    # TODO: constrain queries based on case_id, which (another TODO) should be passed in
}

set case_home_url [export_vars -base "case" { case_id }]

set message_count [db_string message_count_sql "
    select count(*) 
      from sim_messages sm,
           workflow_case_role_party_map wcrmp,
           party_approved_member_map pamm
     where pamm.member_id = :user_id
       and wcrmp.party_id = pamm.party_id
       and wcrmp.role_id = sm.to_role_id
       and wcrmp.case_id = sm.case_id
     [ad_decode $case_id "" "" "and wcrmp.case_id = :case_id"]
"]
set messages_url [export_vars -base ${section_uri}messages { case_id }]

# TODO: decide whether to replace direct sql with this API loop:
#   get a list of cases in which the user participates
#     for each case, do [workflow::case::get_available_actions -case_id case_id -user_id :user_id ]

set task_count [db_string task_count_sql "
    select count(wcea.enabled_action_id) 
      from workflow_case_enabled_actions wcea,
           workflow_case_role_party_map wcrpm,
           workflow_actions wa,
           party_approved_member_map pamm
     where pamm.member_id = :user_id
       and wcrpm.party_id = pamm.party_id
       and wcrpm.case_id = wcea.case_id
       and wcrpm.role_id = wa.assigned_role
       and wa.action_id = wcea.action_id
       and wcea.enabled_state = 'enabled'
    [ad_decode $case_id "" "" "and wcea.case_id = :case_id"]
"]

set tasks_url [export_vars -base ${section_uri}tasks { case_id }]
set portfolio_url [export_vars -base ${section_uri}portfolio { case_id }]
set about_sim_url [export_vars -base ${section_uri}about-sim { case_id }]

# TODO: exclude records where wcrpm.party_id includes current user
db_multirow -extend { character_url } roles select_roles "
    select wcrpm.role_id,
           wr.pretty_name as role_name,
           scx.name,
           scx.title
      from workflow_case_role_party_map wcrpm,
           workflow_roles wr,
           sim_roles sr,
           sim_charactersx scx
     where wcrpm.case_id = :case_id
       and wr.role_id = wcrpm.role_id
       and sr.role_id = wcrpm.role_id
       and scx.object_id = sr.character_id
" {
    set character_url [simulation::object::url -name $name]
}


