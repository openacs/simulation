ad_page_contract {
    The index page for SimInst
}

set page_title "Simulations in Development"
set context [list $page_title]
set package_id [ad_conn package_id]

permission::require_permission -object_id $package_id -privilege sim_inst
set admin_p [permission::permission_p -object_id $package_id -privilege admin]
set base_url [apm_package_url_from_id $package_id]
set add_url "${base_url}/siminst/simulation-new"

#---------------------------------------------------------------------
# dev_sims: simulations in development
#---------------------------------------------------------------------

template::list::create \
    -name dev_sims \
    -multirow dev_sims \
    -actions "{New Simulation From Template} $add_url" \
    -no_data "No Simulations are in Development" \
    -elements {
        pretty_name {
            label "Simulation"
            orderby upper(w.pretty_name)
        }
        role_count {
            label "Roles"
        }
        role_empty_count {
            label "Roles without Characters"
        }
        prop_count {
            label "Props"
        }
        prop_empty_count {
            label "Missing props"
        }
        delete {
            display_template {
                Delete
            }
        }
        copy {
            display_template {
                <u>Copy</u>
            }
        }
        cast {
            link_url_col cast_url
            display_template {
                Begin casting
            }
        }
    }

# if user is admin, show all.  otherwise, show only records owned by user
if { $admin_p } {
    set sim_in_dev_filter_sql ""
} else {
    set sim_in_dev_filter_sql "and ao.creation_user = :user_id"
}

db_multirow -extend { cast_url } dev_sims select_dev_sims "
    select w.workflow_id,
           w.pretty_name,
           (select count(*) 
              from sim_roles sr,
                   workflow_roles wr
             where wr.workflow_id = w.workflow_id) as role_count,
           (select count(*) 
              from sim_roles sr,
                   workflow_roles wr
             where wr.workflow_id = w.workflow_id
               and character_id is null) as role_empty_count,
           (select count(*) 
              from sim_task_object_map stom,
                   workflow_actions wa
             where stom.task_id = wa.action_id
               and wa.workflow_id = w.workflow_id) as prop_count,
           (select count(*) 
              from sim_task_object_map stom,
                   workflow_actions wa
             where stom.task_id = wa.action_id
               and wa.workflow_id = w.workflow_id
               and stom.object_id is null) as prop_empty_count
      from workflows w,
           sim_simulations ss,
           acs_objects ao
     where w.object_id = :package_id
       and ss.simulation_id = w.workflow_id
       and ao.object_id = w.workflow_id
       and ss.sim_type = 'dev_sim'
    $sim_in_dev_filter_sql
" {
    set cast_url [export_vars -base "cast-edit" { workflow_id }]
}


#---------------------------------------------------------------------
# casting_sims: simulations in casting
#---------------------------------------------------------------------

template::list::create \
    -name casting_sims \
    -multirow casting_sims \
    -no_data "No Simulations are in Casting" \
    -elements {
        pretty_name {
            label "Simulation"
            orderby upper(w.pretty_name)
        }
        enroll_type {
            label "Enrollment Type"
        }
        casting_type {
            label "Casting Type"
        }
        users {
            label "Users enrolled"
        }
        delete {
            display_template {
                Delete
            }
        }
        copy {
            display_template {
                <u>Copy</u>
            }
        }
        cast {
            link_url_col cast_url
            display_template {
                Begin casting
            }
        }
    }

# if admin, show all.  otherwise, filter
if { $admin_p } {
    set sim_in_dev_filter_sql ""
} else {
    set sim_in_dev_filter_sql "and ao.creation_user = :user_id"
}

db_multirow -extend { edit_url } casting_sims select_casting_sims "
    select w.workflow_id,
           w.pretty_name,
           ss.enroll_type,
           ss.casting_type,
           (select count(*) 
              from sim_party_sim_map spsm
             where spsm.simulation_id = w.workflow_id) as users
      from workflows w,
           sim_simulations ss,
           acs_objects ao
     where w.object_id = :package_id
       and ss.simulation_id = w.workflow_id
       and ao.object_id = w.workflow_id
       and ss.sim_type = 'dev_sim'
    $sim_in_dev_filter_sql
" {
    set edit_url [export_vars -base "TODO" { workflow_id }]
}
