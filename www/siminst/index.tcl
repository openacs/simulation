ad_page_contract {
    The index page for SimInst
} {
    ds_orderby:optional
    cs_orderby:optional
} 

set page_title "SimInst"
set context [list $page_title]
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set package_uri [apm_package_url_from_id $package_id]

set help_url "${package_uri}object/[parameter::get -package_id $package_id -parameter SimInstHelpFile]"

permission::require_permission -object_id $package_id -privilege sim_inst
set admin_p [permission::permission_p -object_id $package_id -privilege admin]
set base_url $package_uri

#---------------------------------------------------------------------
# dev_sims: simulations in development
#---------------------------------------------------------------------

template::list::create \
    -name dev_sims \
    -multirow dev_sims \
    -no_data "No Simulations are in Development" \
    -sub_class "narrow" \
    -orderby_name ds_orderby \
    -elements {
        edit {
            sub_class narrow
            link_url_eval {[export_vars -base wizard { workflow_id }]}
            display_template {
                <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border="0" alt="Edit">
            }
        }
        pretty_name {
            label "Simulation"
            orderby upper(w.pretty_name)
            link_url_eval {[export_vars -base wizard { workflow_id }]}
        }
        state_pretty {
            label "State"
        }
        description {
            label "Description"
            display_template {@dev_sims.description;noquote@}

        }
        delete {
            sub_class narrow
            link_url_col delete_url
            link_html { onclick "return confirm('Are you sure you want to delete simulation @dev_sims.pretty_name@?');" }
            display_template {
                <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Delete">
            }
        }
    }

# if user is admin, show all.  otherwise, show only records owned by user
if { $admin_p } {
    set sim_in_dev_filter_sql ""
} else {
    set sim_in_dev_filter_sql "and ao.creation_user = :user_id"
}

db_multirow -extend { state state_pretty clone_url cast_url map_roles_url map_props_url sim_tasks_url delete_url prop_empty_count } dev_sims select_dev_sims "
    select w.workflow_id,
           w.pretty_name,
           w.description,
           w.description_mime_type,
           (select count(*) 
              from sim_roles sr,
                   workflow_roles wr
             where sr.role_id = wr.role_id
               and wr.workflow_id = w.workflow_id) as role_count,
           (select sum(coalesce(attachment_num,0))
              from sim_tasks st,
                   workflow_actions wa
             where st.task_id = wa.action_id
               and wa.workflow_id = w.workflow_id) as prop_count,
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
    [template::list::orderby_clause -orderby -name "dev_sims"]
" {
    set description [ad_html_text_convert -from $description_mime_type -maxlen 200 -- $description]

    set state [simulation::template::get_inst_state -workflow_id $workflow_id]

    if { [simulation::template::ready_for_casting_p -state $state] } {
        set cast_url [export_vars -base "${base_url}siminst/simulation-casting" { workflow_id return_url {[ad_return_url]}}]
    } else {
        set cast_url ""
    }
    set map_roles_url [export_vars -base "${base_url}siminst/map-characters" { workflow_id }]
    set sim_tasks_url [export_vars -base "${base_url}siminst/map-tasks" { workflow_id }]
    set delete_url [export_vars -base "${base_url}siminst/simulation-delete" { workflow_id }]
    set state_pretty [simulation::template::get_state_pretty -state $state]

    set clone_url [export_vars -base "${base_url}siminst/template-clone" { workflow_id }]
}


#---------------------------------------------------------------------
# casting_sims: simulations in casting
#---------------------------------------------------------------------

template::list::create \
    -name casting_sims \
    -multirow casting_sims \
    -no_data "No Simulations are in Casting" \
    -orderby_name cs_orderby \
    -elements {
        pretty_name {
            label "Simulation"
            orderby upper(w.pretty_name)
        }
        n_users {
            label "Users enrolled"
            html { align center }
        }
        n_cases {
            label "Cases"
            html { align center }
        }
        case_start {
            label "Start date"            
	    orderby case_start
        }
        start_now {
            label "Start"
            sub_class narrow
            display_template {
                <a href="@casting_sims.start_url@">Start immediately</a>
            }
        }
        delete {
            sub_class narrow
            link_url_col delete_url
            link_html { onclick "return confirm('Are you sure you want to delete simulation @casting_sims.pretty_name@?');" }
            display_template {
                <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Edit">
            }
        }
    }

# if admin, show all.  otherwise, filter
if { $admin_p } {
    set sim_in_dev_filter_sql ""
} else {
    set sim_in_dev_filter_sql "and ao.creation_user = :user_id"
}

db_multirow -extend { edit_url delete_url start_url } casting_sims select_casting_sims "
    select w.workflow_id,
           w.pretty_name,
           (select count(distinct u.user_id) 
              from sim_party_sim_map spsm,
                   party_approved_member_map pamm,
                   users u
             where spsm.simulation_id = w.workflow_id
               and spsm.type in ('auto_enroll', 'enrolled')
               and spsm.party_id = pamm.party_id
               and pamm.member_id = u.user_id) as n_users,
           to_char(ss.case_start, 'YYYY-MM-DD') as case_start,
           (select count(*)
            from   workflow_cases c
            where  c.workflow_id = w.workflow_id) as n_cases
      from workflows w,
           sim_simulations ss,
           acs_objects ao
     where w.object_id = :package_id
       and ss.simulation_id = w.workflow_id
       and ao.object_id = w.workflow_id
       and ss.sim_type = 'casting_sim'
    $sim_in_dev_filter_sql
    [template::list::orderby_clause -orderby -name "casting_sims"]
" {
    set delete_url [export_vars -base "${base_url}siminst/simulation-delete" { workflow_id }]
    set start_url [export_vars -base "simulation-start" { workflow_id }]

    set n_users [lc_numeric $n_users]
    set n_cases [lc_numeric $n_cases]
}
