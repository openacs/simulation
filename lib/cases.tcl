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

# TODO: add link to simplay/case for each case
set package_id [ad_conn package_id]

set elements {
    label {
        label "Case"
        orderby upper(w.pretty_name)
        link_url_eval {[export_vars -base [ad_conn package_url]simplay/case { case_id }]}
    }
    pretty_name {
        label "Simulation"
        orderby upper(w.pretty_name)
    }
    status {
        label "Status"
    }
    num_user_tasks {
        label "Your Tasks"
        display_template {
            <if @cases.num_user_tasks@ gt 0>@cases.num_user_tasks@</if>
        }
        html { align right }
    }
}

template::list::create \
    -name cases \
    -multirow cases \
    -no_data "You are not in any active simulation cases." \
    -elements $elements 

db_multirow cases select_cases "
    select distinct wc.case_id,
           sc.label,
           w.pretty_name,
           case when (select count(*)
                        from workflow_case_enabled_actions wcea
                       where wcea.case_id = wc.case_id
                         and wcea.enabled_state = 'enabled')=0 then 'Completed'
                else 'Active'
           end as status,
           (select count(distinct wa2.action_id)
            from   workflow_case_enabled_actions wcea2,
                   workflow_actions wa2,
                   workflow_case_role_party_map wcrpm2
            where  wcea2.case_id = wc.case_id
            and    wcea2.enabled_state = 'enabled'
            and    wa2.action_id = wcea2.action_id
            and    wcrpm2.role_id = wa2.assigned_role
            and    wcrpm2.party_id = :party_id
            and    wcrpm2.case_id = wc.case_id) as num_user_tasks
      from workflow_cases wc,
           sim_cases sc,
           workflow_case_role_party_map wcrpm,
           workflows w
     where wcrpm.party_id = :party_id
       and wc.case_id = wcrpm.case_id
       and sc.sim_case_id = wc.object_id
       and w.workflow_id = wc.workflow_id
[template::list::orderby_clause -orderby -name "cases"]
"
