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
        label "Simulation"
        orderby upper(w.pretty_name)
        link_url_eval {[export_vars -base [ad_conn package_url]simplay/case { case_id role_id }]}
    }
    label {
        label "Case"
        orderby upper(w.pretty_name)
    }
    role_pretty {
        label "Role"
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
    select wc.case_id,
           sc.label,
           w.pretty_name,
           case when (select count(*)
                        from workflow_case_enabled_actions wcea
                       where wcea.case_id = wc.case_id
                         and wcea.enabled_state = 'enabled')=0 then 'Completed'
                else 'Active'
           end as status,
           r.role_id,
           r.pretty_name as role_pretty,
           (select count(distinct wa2.action_id)
            from   workflow_case_enabled_actions wcea2,
                   workflow_actions wa2,
                   workflow_case_role_party_map wcrpm2
            where  wcea2.case_id = wc.case_id
            and    wcea2.enabled_state = 'enabled'
            and    wa2.action_id = wcea2.action_id
            and    wcrpm2.role_id = wa2.assigned_role
            and    wcrpm2.party_id = :party_id
            and    wcrpm2.role_id = r.role_id
            and    wcrpm2.case_id = wc.case_id) as num_user_tasks
      from workflow_cases wc,
           sim_cases sc,
           workflow_case_role_party_map wcrpm,
           workflows w,
           workflow_roles r
     where wcrpm.party_id = :party_id
       and r.role_id = wcrpm.role_id
       and wc.case_id = wcrpm.case_id
       and sc.sim_case_id = wc.object_id
       and w.workflow_id = wc.workflow_id
[template::list::orderby_clause -orderby -name "cases"]
"
