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
            link_url_col edit_url
            label "Simulation"
            orderby upper(w.pretty_name)
        }
        role_count {
            label "Roles"
            link_url_col map_roles_url
            display_template {
                @dev_sims.role_count@ <if @dev_sims.role_empty_count@ gt 0>(@dev_sims.role_empty_count@ incomplete)</if>
            }
        }
        tasks {
            label "Tasks"
            link_url_col sim_tasks_url
            display_template {
                @dev_sims.tasks@<if @dev_sims.prop_empty_count@ gt 0>, with @dev_sims.prop_empty_count@ incomplete prop</if><if @dev_sims.prop_empty_count@ gt 1>s</if>
            }
        }
        delete {
            sub_class narrow
            link_url_col delete_url
            display_template {
                <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Edit"></a>
            }
        }
        copy {
            display_template {
                <u>Copy</u>
            }
        }
        cast {
            display_template {
                <if @dev_sims.cast_url@ not nil>
                  <a href="@dev_sims.cast_url@">Begin casting</a>
                </if>
                <else>
                  Not Ready for Casting
                </else>
            }
        }
    }

# if user is admin, show all.  otherwise, show only records owned by user
if { $admin_p } {
    set sim_in_dev_filter_sql ""
} else {
    set sim_in_dev_filter_sql "and ao.creation_user = :user_id"
}

db_multirow -extend { cast_url map_roles_url map_props_url sim_tasks_url delete_url prop_empty_count } dev_sims select_dev_sims "
    select w.workflow_id,
           w.pretty_name,
           (select count(*) 
              from sim_roles sr,
                   workflow_roles wr
             where sr.role_id = wr.role_id
               and wr.workflow_id = w.workflow_id) as role_count,
           (select count(*) 
              from sim_roles sr,
                   workflow_roles wr
             where sr.role_id = wr.role_id
               and wr.workflow_id = w.workflow_id
               and character_id is null) as role_empty_count,
           (select sum(coalesce(attachment_num,0))
              from sim_tasks st,
                   workflow_actions wa
             where st.task_id = wa.action_id
               and wa.workflow_id = w.workflow_id) as prop_count,
           (select count(*) 
              from sim_task_object_map stom,
                   workflow_actions wa
             where stom.task_id = wa.action_id
               and wa.workflow_id = w.workflow_id) as prop_not_empty_count,
           (select count(*)
              from workflow_actions wa
             where wa.workflow_id = w.workflow_id) as tasks           
      from workflows w,
           sim_simulations ss,
           acs_objects ao
     where w.object_id = :package_id
       and ss.simulation_id = w.workflow_id
       and ao.object_id = w.workflow_id
       and ss.sim_type = 'dev_sim'
    $sim_in_dev_filter_sql
" {
    set prop_empty_count [expr $prop_count - $prop_not_empty_count]
    if { [simulation::template::ready_for_casting_p -role_empty_count $role_empty_count -prop_empty_count $prop_empty_count] } {
        set cast_url [export_vars -base "${base_url}siminst/simulation-casting" { workflow_id return_url {[ad_return_url]}}]
    } else {
        set cast_url ""
    }
    set map_roles_url [export_vars -base "${base_url}siminst/map-characters" { workflow_id }]
    set sim_tasks_url [export_vars -base "${base_url}siminst/map-tasks" { workflow_id }]
    set delete_url [export_vars -base "${base_url}siminst/simulation-delete" { workflow_id }]
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
            link_url_col edit_url
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
        case_start {
            label "Start date"            
        }
        delete {
            sub_class narrow
            link_url_col delete_url
            display_template {
                <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Edit"></a>
            }
        }
        copy {
            display_template {
                <u>Copy</u>
            }
        }
    }

# if admin, show all.  otherwise, filter
if { $admin_p } {
    set sim_in_dev_filter_sql ""
} else {
    set sim_in_dev_filter_sql "and ao.creation_user = :user_id"
}

db_multirow -extend { edit_url delete_url edit_p } casting_sims select_casting_sims "
    select w.workflow_id,
           w.pretty_name,
           ss.enroll_type,
           ss.casting_type,
           (select count(*) 
              from sim_party_sim_map spsm
             where spsm.simulation_id = w.workflow_id) as users,
           to_char(ss.case_start, 'YYYY-MM-DD') as case_start
      from workflows w,
           sim_simulations ss,
           acs_objects ao
     where w.object_id = :package_id
       and ss.simulation_id = w.workflow_id
       and ao.object_id = w.workflow_id
       and ss.sim_type = 'casting_sim'
    $sim_in_dev_filter_sql
" {
    set edit_url [export_vars -base "${base_url}siminst/simulation-casting-2" { workflow_id }]
    set delete_url [export_vars -base "${base_url}siminst/simulation-delete" { workflow_id }]
}
