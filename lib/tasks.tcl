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
}

if { [empty_string_p $case_id] } {
    unset case_id
}

set package_id [ad_conn package_id]
set adminplayer_p [permission::permission_p -object_id $package_id -privilege sim_adminplayer]

if { !$adminplayer_p } {
    if { ![exists_and_not_null case_id] || ![exists_and_not_null role_id] } {
        error "You must supply both case_id and role_id"
    }
}

if { [exists_and_not_null case_id] } {
    set num_enabled_actions [db_string select_num_enabled_actions { 
        select count(*) 
        from   workflow_case_enabled_actions 
        where  case_id = :case_id
        and    enabled_state = 'enabled'
    }]
    set complete_p [expr $num_enabled_actions == 0]
} else {
    set complete_p 0
}

set elements {
    name {
        link_url_col task_url
        label "Task"
    }
    role {
        label "Role"
        hide_p {[ad_decode [exists_and_not_null case_id] 1 1 0]}
        display_col role_pretty
    }
    case_label {
        label "Case"
        hide_p {[ad_decode [exists_and_not_null case_id] 1 1 0]}
    }
    sim_name {
        label "Simulation"
        hide_p {[ad_decode [exists_and_not_null case_id] 1 1 0]}
    }
}

template::list::create \
    -name tasks \
    -multirow tasks \
    -no_data "You don't have any tasks." \
    -elements $elements

# NOTE: Our "pick case and role" design of simplay doesn't work if a child workflow uses per_user mapping
# because the role in the child workflow will then no longer match any role in the top case.

db_multirow -extend { task_url } tasks select_tasks "
    select wcaa.enabled_action_id,
           wa.pretty_name as name,
           wcaa.top_case_id as case_id,
           wcaa.real_role_id as role_id,
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
       and topwc.case_id = wcaa.top_case_id
       and sc.sim_case_id = topwc.object_id
       and w.workflow_id = topwc.workflow_id
       and wr.role_id = wcaa.real_role_id
       [ad_decode [exists_and_not_null role_id] 1 "and wcaa.real_role_id = :role_id" ""]
       [ad_decode [exists_and_not_null case_id] 1 "and wcaa.top_case_id = :case_id" "and exists (select 1 
                   from   workflow_case_role_user_map 
                   where  case_id = wcaa.real_case_id 
                   and    role_id = wcaa.real_role_id 
                   and    user_id = :user_id)"]
    order by wa.sort_order
" {
    set task_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/task-detail" { enabled_action_id case_id role_id  }]
}


