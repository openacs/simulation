simulation::include_contract {
    Displays a list of cases for the specified user.

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    party_id {
        default_value ""
    }
    case_admin_order {
	required_p 0
    }
}


set package_id [ad_conn package_id]
set user_id [auth::get_user_id]

set elements {
    pretty_name {
        label {[_ simulation.Simulation]}
        orderby upper(w.pretty_name)
    }
    label {
        label {[_ simulation.Case]}
        orderby label
        link_url_eval {[export_vars -base [ad_conn package_url]simplay/case-admin { case_id }]}
    }
    num_roles {
	label {[_ simulation.Roles]}
	orderby num_roles
    }
    status {
	label {[_ simulation.Status]}
	orderby status
    }
}

template::list::create \
    -name cases \
    -multirow cases \
    -no_data [_ simulation.lt_You_are_not_administe] \
    -orderby_name case_admin_order \
    -elements $elements 

db_multirow cases select_cases "
    select wc.case_id,
           sc.label,
           w.pretty_name,
           case when (select count(*)
                        from workflow_case_enabled_actions wcea
                       where wcea.case_id = wc.case_id) = 0 then 'Completed'
                else 'Active'
           end as status,
           (select count(*)
               from workflow_roles wr
               where wr.workflow_id = w.workflow_id) as num_roles
      from workflow_cases wc,
           sim_cases sc,
           workflows w,
           acs_objects ao
     where wc.workflow_id = w.workflow_id
       and sc.sim_case_id = wc.object_id
       and w.workflow_id = ao.object_id
       and ao.creation_user = :user_id
    [template::list::orderby_clause -orderby -name "cases"]
"
