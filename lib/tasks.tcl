 simulation::include_contract {
    Displays a list of tasks for a given user_id

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    user_id {
        default_value ""
    }
    case_id {
        default_value ""
    }
    role_id {
        default_value ""
    }
    workflow_id {
        default_value ""
    }
}

if { [empty_string_p $case_id] } {
    unset case_id
}

if { [empty_string_p $user_id] } {
    set user_id [ad_conn user_id]
}

set package_id [ad_conn package_id]
set adminplayer_p [permission::permission_p -object_id $package_id -privilege sim_adminplayer]

if { !$adminplayer_p } {
    if { ![exists_and_not_null case_id] || ![exists_and_not_null role_id] } {
        error [_ simulation.lt_You_must_supply_both]
    }
}

if { [exists_and_not_null case_id] } {
    set num_enabled_actions [db_string select_num_enabled_actions { 
        select count(*) 
        from   workflow_case_enabled_actions 
        where  case_id = :case_id
    }]
    set complete_p [expr $num_enabled_actions == 0]
} else {
    set complete_p 0
}

set elements {
    name {
        link_url_col task_url
        label {[_ simulation.Task]}
    }
    role {
        label {[_ simulation.Role]}
        hide_p {[ad_decode [exists_and_not_null case_id] 1 1 0]}
        display_col role_pretty
    }
    case_label {
        label {[_ simulation.Case]}
        hide_p {[ad_decode [exists_and_not_null case_id] 1 1 0]}
    }
    sim_name {
        label {[_ simulation.Simulation]}
        hide_p {[ad_decode [exists_and_not_null case_id] 1 1 0]}
    }
}

set bulk_actions ""
set role_values ""
set task_values ""
set bulk_p 0
if { ![empty_string_p $workflow_id] } {
    # We are listing tasks across cases in a workflow. 
    # Enable the role filter.

    ad_page_contract {
    } {
        search_terms:optional
    }

    ad_form -name search -export { workflow_id } -form {
        {search_terms:text,optional {label {[_ simulation.lt_Restrict_to_previous]}}}
    }

    set role_values [db_list_of_lists select_roles {
        select wr.pretty_name,
               wr.role_id
          from workflow_roles wr
        where wr.workflow_id = :workflow_id
          and exists (select 1
                      from workflow_case_role_user_map wcrum,
                           workflow_case_assigned_actions wcaa
                      where wcrum.case_id = wcaa.case_id
                        and wcrum.role_id = wcaa.role_id
                        and wcrum.role_id = wr.role_id
                        and wcrum.user_id = :user_id
                      )
    }]

    if { [llength $role_values] <= 1 } {
        # Don't display a filter with one option
        set role_values {}
    }

    set task_values [db_list_of_lists select_tasks {
        select wa.pretty_name,
               wa.action_id
        from workflow_actions wa
        where wa.workflow_id = :workflow_id
          and exists (select 1
                      from workflow_case_role_user_map wcrum,
                           workflow_case_assigned_actions wcaa
                      where wcrum.case_id = wcaa.case_id
                        and wcrum.role_id = wcaa.role_id
                        and wcaa.action_id = wa.action_id
                        and wcrum.user_id = :user_id
                      )
    }]

    if { [llength $task_values] <= 1 } {
        # Don't display a filter with one option
        set task_values {}
    }

    set bulk_actions [list [_ simulation.Respond] task-detail [_ simulation.lt_Take_action_on_select]]
    set bulk_p 1
}

template::list::create \
    -name tasks \
    -multirow tasks \
    -no_data [_ simulation.lt_You_dont_have_any_tas] \
    -key "enabled_action_id" \
    -elements $elements \
    -filters {
        role_id {
            label {[_ simulation.Role]}
            values $role_values
            hide_p {[ad_decode [llength $role_values] 0 t f]}
        }
        task_id {
            label {[_ simulation.Task]}
            values $task_values
            hide_p {[ad_decode [llength $task_values] 0 t f]}
        }
        workflow_id {
            hide_p t
        }
    } \
    -bulk_actions $bulk_actions \
    -bulk_action_export_vars { bulk_p }

# NOTE: Our "pick case and role" design of simplay doesn't work if a child workflow uses per_user mapping
# because the role in the child workflow will then no longer match any role in the top case.

set search_clause ""
if { [exists_and_not_null search_terms] } {
    set search_terms_lower [string trim [string tolower $search_terms]]
    set search_clause "
       exists (select 1
              from sim_messages sm,
                   cr_revisions cr
              where sm.message_id = cr.revision_id
                and sm.entry_id = (select max(wcl.entry_id)
                                    from workflow_case_log wcl,
                                         workflow_fsm_actions wfa,
                                         workflow_case_fsm wcf
                                    where wcl.case_id = sm.case_id
                                    and wcl.action_id = wfa.action_id
                                    and wcf.case_id = wcl.case_id
                                    and wfa.new_state = wcf.current_state)
                and sm.case_id = wcaa.case_id
                and (lower(cr.content) like '%$search_terms_lower%' or
                     lower(cr.title) like '%$search_terms_lower%')  
             )"
}

db_multirow -extend { task_url } tasks select_tasks "
    select wcaa.enabled_action_id,
           wa.pretty_name as name,
           wcaa.case_id,
           sc.label as case_label,
           w.pretty_name as sim_name,
           wr.pretty_name as role_pretty,
           wr.role_id
      from workflow_case_assigned_actions wcaa,
           workflow_actions wa,
           workflow_cases topwc,
           sim_cases sc,
           workflows w,
           workflow_roles wr
     where wa.action_id = wcaa.action_id
       and topwc.case_id = wcaa.case_id
       and sc.sim_case_id = topwc.object_id
       and w.workflow_id = topwc.workflow_id
       and wr.role_id = wcaa.role_id
       [ad_decode $search_clause "" "" "and $search_clause"]
       [ad_decode [exists_and_not_null workflow_id] 1 "and w.workflow_id = :workflow_id" ""]
       [ad_decode [exists_and_not_null role_id] 1 "and wcaa.role_id = :role_id" ""]
       [ad_decode [exists_and_not_null case_id] 1 "and wcaa.case_id = :case_id" "and exists (select 1 
                   from   workflow_case_role_user_map 
                   where  case_id = wcaa.case_id 
                   and    role_id = wcaa.role_id 
                   and    user_id = :user_id)"]
    order by wa.sort_order
" {
    set task_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/task-detail" { enabled_action_id case_id role_id bulk_p }]
}
