simulation::include_contract {
    Displays a list of simulations for admins

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
}

set package_id [ad_conn package_id]

######################################################################
#
# live_sims
#
# A list of currently active simulations
#
######################################################################

#---------------------------------------------------------------------
# live_sims list
#---------------------------------------------------------------------

set elements {
    pretty_name {
        label "Simulation"
        orderby upper(w.pretty_name)
        link_url_col edit_url
    }
    cases {
        label "Cases"
        orderby cases
    }
}

template::list::create \
    -name live_sims \
    -multirow live_sims \
    -no_data "No currently active simulations." \
    -elements $elements 

#---------------------------------------------------------------------
# live_sims multirow
#---------------------------------------------------------------------

db_multirow -extend {edit_url} live_sims select_live_sims "
    select w.pretty_name,
           (select count(case_id)
              from workflow_cases
             where workflow_id = w.workflow_id) as cases
      from workflows w, sim_simulations ss
     where w.package_key = :package_id
       and ss.simulation_id = w.workflow_id
       and ss.case_start <= now()
       and ss.case_end   >= now()
" {
    set edit_url [export_vars -base "simulation-edit" { simulation_id }]
}
