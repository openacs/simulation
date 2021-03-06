simulation::include_contract {
    Displays grouped list of simulations in development and casting for the current simulation package instance.

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
}

######################################################################
# Set general variables

set package_id [ad_conn package_id]
set user_id [auth::get_user_id]
set base_url [apm_package_url_from_id $package_id]
set add_url "${base_url}/siminst/simulation-new"
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

#---------------------------------------------------------------------
# sims: simulations in development or casting
#---------------------------------------------------------------------

template::list::create \
    -name sims \
    -multirow sims \
    -actions "{[_ simulation.lt_New_Simulation_From_T]} $add_url" \
    -no_data "[_ simulation.lt_You_have_no_Simulatio]" \
    -elements {
        status {
            label "[_ simulation.Status]"
        }
        count {
            label "[_ simulation.Count]"
        }
    }

# if user is admin, show all.  otherwise, show only records owned by user
if { $admin_p } {
    set sim_filter_sql ""
} else {
    set sim_filter_sql "and ao.creation_user = :user_id"
}

db_multirow sims select_sims "
    select ss.sim_type as status,
           count(w.workflow_id) as count
      from workflows w,
           sim_simulations ss,
           acs_objects ao
     where w.object_id = :package_id
       and ss.simulation_id = w.workflow_id
       and ao.object_id = w.workflow_id
       and (ss.sim_type = 'dev_sim' or ss.sim_type = 'casting_sim')
     $sim_filter_sql
     group by ss.sim_type
" 
