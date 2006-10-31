simulation::include_contract {
    Displays a menu/control bar for users in a sim

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    case_id {}
    role_id {}
}

set current_url [export_vars -base [ad_conn url] { case_id role_id }]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set section_uri [apm_package_url_from_id $package_id]simplay/
set page_role_id $role_id

simulation::case::get -case_id $case_id -array case

set workflow_id $case(workflow_id)

set case_name $case(label)

db_1row getflags {
    select show_contacts_p, show_states_p
      from sim_simulations
     where simulation_id=:workflow_id}

set case_home_url [export_vars -base ${section_uri}case { case_id role_id }]

set message_count [db_string message_count_sql "
    select count(*) 
      from sim_messagesx sm
     where (sm.to_role_id = :role_id or sm.from_role_id = :role_id)
       and sm.case_id = :case_id
"]
set messages_url [export_vars -base ${section_uri}messages { case_id role_id }]

set task_count [db_string task_count_sql {
    select count(wcaa.action_id) 
      from workflow_case_assigned_actions wcaa
     where wcaa.role_id = :role_id
       and wcaa.case_id = :case_id
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

set role(character_url) [export_vars -base [simulation::object::url -name $role(character_name) -simplay 1] { case_id role_id }]

array set thumbnail [lindex \
  [util_list_of_ns_sets_to_list_of_lists -list_of_ns_sets \
    [bcms::item::list_related_items -item_id $role(character_item_id) \
      -relation_tag "thumbnail" -return_list]] 0]

if { [exists_and_not_null thumbnail(name)] \
     && [exists_and_not_null thumbnail(live_revision)] } {
      set role(thumbnail_url) \
        [simulation::object::content_url -name $thumbnail(name)]
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
    set character_url [export_vars -base [simulation::object::url -name $character_name -simplay 1] { case_id {role_id $page_role_id} {recipient_role_id $role_id} }]
}

set notifications_url [export_vars -base ${section_uri}notifications { case_id role_id }]

set yp_url [export_vars -base ${section_uri}yellow-pages { case_id role_id }]

set map_url [export_vars -base ${section_uri}map { case_id role_id }]

set help_url [export_vars -base "${section_uri}object/[parameter::get -parameter SimPlayHelpFile]" { case_id role_id }]

set history_url [export_vars -base "${section_uri}object/[parameter::get -parameter SieberdamHistoryFile]" { case_id role_id }]

set curr_state [_ simulation.curr_state]

db_1row get_state {
    select wfs.pretty_name as state_name, 
           s.show_states_p
    from   workflow_fsm_states wfs,
           workflow_case_fsm wcf,
           workflow_cases wc,
           sim_simulations s
    where  wcf.case_id = wc.case_id and
           wcf.current_state = wfs.state_id and
           s.simulation_id = wc.workflow_id and
           wc.workflow_id = :workflow_id and
           wcf.case_id = :case_id and
           wcf.parent_enabled_action_id is NULL
}
