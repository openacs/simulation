# an includelet showing messages and tasks for a user

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set section_uri [apm_package_url_from_id $package_id]simplay/
set adminplayer_p [permission::permission_p -object_id $package_id -privilege sim_adminplayer]

if { !$adminplayer_p } {
    # TODO: constrain queries based on case_id, which (another TODO) should be passed in
}


set message_count [db_string message_count_sql "
    select count(*) 
      from sim_messages sm,
           workflow_case_role_party_map wcrmp,
           party_approved_member_map pamm
     where pamm.member_id = :user_id
       and wcrmp.party_id = pamm.party_id
       and wcrmp.role_id = sm.to_role_id
       and wcrmp.case_id = sm.case_id
"]
set messages_url ${section_uri}messages


# TODO: decide whether to replace direct sql with this API loop:
#   get a list of cases in which the user participates
#     for each case, do [workflow::case::get_available_actions -case_id case_id -user_id :user_id ]

set task_count [db_string task_count_sql "
    select count(wcea.enabled_action_id) 
      from workflow_case_enabled_actions wcea,
           workflow_case_role_party_map wcrmp,
           workflow_actions wa,
           party_approved_member_map pamm
     where pamm.member_id = :user_id
       and wcrmp.party_id = pamm.party_id
       and wcrmp.case_id = wcea.case_id
       and wcrmp.role_id = wa.assigned_role
       and wa.action_id = wcea.action_id
"]

set tasks_url ${section_uri}tasks