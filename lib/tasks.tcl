simulation::include_contract {
    Displays a list of tasks for a given user_id

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    user_id {
        default_value ""
    }
}

set package_id [ad_conn package_id]

set elements {
    case_name {
        label "Case"
    }
    name {
        link_url_col task_url
        label "Task"
    }
}

template::list::create \
    -name tasks \
    -multirow tasks \
    -no_data "You don't have any tasks." \
    -elements $elements 

# TODO: make case_name be a combo of simulation name and case #
db_multirow -extend { task_url } tasks select_tasks "
    select wcea.enabled_action_id,
           wa.pretty_name as name,
           wcea.case_id
      from workflow_case_enabled_actions wcea,
           workflow_case_role_party_map wcrmp,
           workflow_actions wa,
           party_approved_member_map pamm
     where pamm.member_id = :user_id
       and wcrmp.party_id = pamm.party_id
       and wcrmp.case_id = wcea.case_id
       and wcrmp.role_id = wa.assigned_role
       and wa.action_id = wcea.action_id
" {
    set task_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/task-detail" { enabled_action_id }]
}