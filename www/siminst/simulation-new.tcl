ad_page_contract {
    A list of available simulation templates
} {
    orderby:optional
}

set page_title "New Simulation From Template"
set context [list [list . "SimInst"] $page_title]
set package_id [ad_conn package_id]

#---------------------------------------------------------------------
# Templates ready for mapping
#---------------------------------------------------------------------

template::list::create \
    -name ready_templates \
    -multirow ready_templates \
    -no_data "No templates are ready for mapping" \
    -elements {
        pretty_name {
            label "Templates Ready for Use"
            orderby upper(w.pretty_name)
        }
        suggested_duration {
            label "Suggested Duration"
            orderby suggested_duration
        }
        number_of_roles {
            label "Roles"
            orderby number_of_roles
            html { align center }
        }
        number_of_tasks {
            label "Tasks"
            html { align center }
	    orderby number_of_tasks
        }
        map {
            label ""
            link_url_col map_url
            display_template {
                Begin Development
            }
        }    
    }

db_multirow -extend {map_url} ready_templates select_ready_templates "
select workflow_id,
       suggested_duration,
       pretty_name,
       (select count(*)
        from workflow_roles
        where workflow_id = w.workflow_id) as number_of_roles,
       (select count(*)
        from  workflow_actions wa
        where wa.workflow_id = w.workflow_id
        and   wa.trigger_type = 'user') as number_of_tasks
  from sim_simulations ss,
       workflows w
 where ss.simulation_id = w.workflow_id
   and w.object_id = :package_id
   and ss.sim_type = 'ready_template'
    [template::list::orderby_clause -orderby -name "ready_templates"]
" {
    set map_url [export_vars -base "map-create" { workflow_id }]

    if { [empty_string_p $suggested_duration] } {
        set suggested_duration "none specified"
    }
}
