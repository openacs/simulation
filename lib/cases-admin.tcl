simulation::include_contract {
    Displays a list of cases for the specified user.

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    party_id {
        default_value ""
    }
}

set package_id [ad_conn package_id]
set user_id [auth::get_user_id]

set elements {
    label {
        label "Case"
        orderby upper(w.pretty_name)
        link_url_eval {[export_vars -base [ad_conn package_url]simplay/case-admin { case_id }]}
    }
    pretty_name {
        label "Simulation"
        orderby upper(w.pretty_name)
    }
}

template::list::create \
    -name cases \
    -multirow cases \
    -no_data "You are not administering any active simulation cases." \
    -elements $elements 

db_multirow cases select_cases "
    select wc.case_id,
           sc.label,
           w.pretty_name
      from workflow_cases wc,
           sim_cases sc,
           workflows w,
           acs_objects ao
     where wc.workflow_id = w.workflow_id
       and sc.sim_case_id = wc.object_id
       and w.workflow_id = ao.object_id
       and ao.creation_user = :user_id
       order by w.workflow_id, wc.case_id
"
