simulation::include_contract {
    Displays a menu/control bar for users in a sim

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    case_id {}
    role_id {}
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set section_uri [apm_package_url_from_id $package_id]simplay/

set workflow_id [simulation::case::get_element -case_id $case_id -element workflow_id]    

set case_home_url [export_vars -base "case" { case_id role_id }]

set message_count [db_string message_count_sql {
    select count(*) 
      from sim_messages sm
     where sm.to_role_id = :role_id
       and sm.case_id = :case_id
}]
set messages_url [export_vars -base ${section_uri}messages { case_id role_id }]

set task_count [db_string task_count_sql {
    select count(wcea.enabled_action_id) 
      from workflow_case_enabled_actions wcea,
           workflow_actions wa
     where wa.assigned_role = :role_id
       and wa.action_id = wcea.action_id
       and wcea.case_id = :case_id
}]

set tasks_url [export_vars -base ${section_uri}tasks { case_id role_id }]
set portfolio_url [export_vars -base ${section_uri}portfolio { case_id role_id }]
set about_sim_url [export_vars -base ${section_uri}about-sim { case_id role_id }]

db_1row your_role {
    select wr.role_id,
           wr.pretty_name as role_pretty,
           scx.name as character_name,
           scx.title as character_title,
           scx.item_id as character_item_id
      from workflow_roles wr,
           sim_roles sr,
           sim_charactersx scx,
           cr_items ci
     where wr.role_id = :role_id
       and sr.role_id = wr.role_id
       and scx.item_id = sr.character_id
       and ci.item_id = scx.item_id
       and ci.live_revision = scx.object_id
} -column_array role

set role(character_url) [simulation::object::url -name $role(character_name)]

array set thumbnail [lindex [util_list_of_ns_sets_to_list_of_lists -list_of_ns_sets [bcms::item::list_related_items -item_id $role(character_item_id) -relation_tag "thumbnail" -return_list]] 0]

if { [exists_and_not_null thumbnail(name)] && [exists_and_not_null thumbnail(live_revision)] } {
    set role(thumbnail_url) [simulation::object::content_url -name $thumbnail(name)]
    set role(thumbnail_name) $thumbnail(name)

    array set thumbnail_rev [bcms::revision::get_revision \
                                 -revision_id $thumbnail(live_revision) \
                                 -additional_properties { width height }]
                             
    set role(thumbnail_height) $thumbnail_rev(height)
    set role(thumbnail_width) $thumbnail_rev(width)
}

db_multirow -unclobber -extend { character_url } contacts select_contacts "
    select wr.role_id,
           wr.pretty_name as role_pretty,
           scx.name as character_name,
           scx.title as character_title
      from workflow_cases wc,
           workflow_roles wr,
           sim_roles sr,
           sim_charactersx scx,
           cr_items ci
     where wc.case_id = :case_id
       and wr.workflow_id = wc.workflow_id
       and sr.role_id = wr.role_id
       and scx.item_id = sr.character_id
       and ci.item_id = scx.item_id
       and ci.live_revision = scx.object_id
       and wr.role_id != :role_id
" {
    set character_url [simulation::object::url -name $character_name]
}

set notifications_url [export_vars -base notifications { case_id role_id }]
