simulation::include_contract {
    Displays a list of simulations with task counts for admins.

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
}

set user_id [ad_conn user_id]

template::list::create \
    -name simulations \
    -multirow simulations \
    -no_data "You don't have any tasks." \
    -elements {
        pretty_name {
            label "Simulation"
            link_url_col simulation_url
        }
        number_of_tasks {
            label "Number of tasks"
            html {align center}
        }
    }

db_multirow -extend { simulation_url } simulations simulations {
    select q.* from 
    (select w.workflow_id,
            w.pretty_name,
           (select count(*)
                      from workflow_case_role_user_map wcrum,
                           workflow_case_assigned_actions wcaa,
                           workflow_cases wc
                      where wcrum.case_id = wcaa.case_id
                        and wcrum.role_id = wcaa.role_id
                        and wcaa.case_id = wc.case_id
                        and wc.workflow_id = w.workflow_id
                        and wcrum.user_id = :user_id
                      ) as number_of_tasks
    from workflows w) q
    where q.number_of_tasks > 0
} {
    set simulation_url [export_vars -base tasks-bulk { workflow_id }]
}
