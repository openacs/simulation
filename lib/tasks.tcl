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
}

if { [empty_string_p $case_id] } {
    unset case_id
}

set package_id [ad_conn package_id]

set elements {
    name {
        link_url_col task_url
        label "Task"
    }
    sim_name {
        label "Simulation"
        hide_p {[ad_decode [exists_and_not_null case_id] 1 1 0]}
    }
    case_label {
        label "Case"
        hide_p {[ad_decode [exists_and_not_null case_id] 1 1 0]}
    }
}

template::list::create \
    -name tasks \
    -multirow tasks \
    -no_data "You don't have any tasks." \
    -elements $elements \
    -filters {
        case_id {
            where_clause "wc.case_id = :case_id"
        }
    }

# TODO: make case_name be a combo of simulation name and case #
db_multirow -extend { task_url } tasks select_tasks "
    select wcea.enabled_action_id,
           wa.pretty_name as name,
           wcea.case_id,
           sc.label as case_label,
           w.pretty_name as sim_name
      from workflow_case_enabled_actions wcea,
           workflow_case_role_party_map wcrmp,
           workflow_actions wa,
           party_approved_member_map pamm,
           workflow_cases wc,
           sim_cases sc,
           workflows w
     where wcea.enabled_state = 'enabled'
       and pamm.member_id = :user_id
       and wcrmp.party_id = pamm.party_id
       and wcrmp.case_id = wcea.case_id
       and wcrmp.role_id = wa.assigned_role
       and wa.action_id = wcea.action_id
       and wc.case_id = wcea.case_id
       and sc.sim_case_id = wc.object_id
       and w.workflow_id = wc.workflow_id
    [template::list::filter_where_clauses -and -name "tasks"]
    order by wa.sort_order
" {
    set task_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/task-detail" { enabled_action_id }]
}
