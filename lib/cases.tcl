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

set elements {
    pretty_name {
        label "Cases"
        orderby upper(w.pretty_name)
    }
}

template::list::create \
    -name cases \
    -multirow cases \
    -no_data "You are not in any active simulation cases." \
    -elements $elements 

db_multirow cases select_cases "
    select wc.case_id,
           w.pretty_name
      from workflow_cases wc,
           workflow_case_role_party_map wcrpm,
           workflows w
     where wcrpm.party_id = :party_id
       and wc.case_id = wcrpm.case_id
       and w.workflow_id = wc.workflow_id
    [template::list::orderby_clause -orderby -name "cases"]
"