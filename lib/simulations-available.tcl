simulation::include_contract {
    Displays a list of available simulations

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
    }
}

template::list::create \
    -name avail_sims \
    -multirow avail_sims \
    -no_data "No simulations available to join." \
    -elements $elements 

db_multirow avail_sims select_avail_sims "
    select w.pretty_name
      from workflows w,
           sim_party_sim_map spsm
     where w.workflow_id = spsm.simulation_id
       and spsm.simulation_id = :party_id
    UNION
    select w.pretty_name
      from workflows w,
           sim_simulations ss
     where ss.enroll_start <= now() 
       and ss.enroll_end >= now()
       and ss.enroll_type = 'open'
"