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

db_multirow -extend { task_url } tasks select_tasks "
    select wcea.enabled_action_id,
           wa.pretty_name as name,
           wcea.case_id,
           sc.label as case_label,
           w.pretty_name as sim_name,
           wr.pretty_name as role,
           wr.role_id as role_id
      from workflow_case_enabled_actions wcea,
           workflow_actions wa,
           workflow_cases wc,
           sim_cases sc,
           workflows w,
           workflow_roles wr
     where wcea.enabled_state = 'enabled'
       and wa.action_id = wcea.action_id
       and wr.role_id = wa.assigned_role
       and wc.case_id = wcea.case_id
       and sc.sim_case_id = wc.object_id
       and w.workflow_id = wc.workflow_id
       [ad_decode [exists_and_not_null role_id] 1 "and wr.role_id = :role_id" ""]
       [ad_decode [exists_and_not_null case_id] 1 "and wcea.case_id = :case_id" "and    exists (select 1 from workflow_case_role_user_map where case_id = wc.case_id and wa.assigned_role = role_id and user_id = :user_id)"]

    order by wa.sort_order
" {
    set task_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/task-detail" { enabled_action_id case_id role_id  }]
}
