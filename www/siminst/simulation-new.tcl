ad_page_contract {
    A list of available simulation templates
}

set page_title "New Simulation From Template"
set context [list [list . "SimInst"] $page_title]
set package_id [ad_conn package_id]

#---------------------------------------------------------------------
# Templates ready for mapping
#---------------------------------------------------------------------

# TODO: new columns:
# number_of_roles
# number_of_roles_not_cast
# number_of_tasks
# number_of_tasks_undescribed
# number_of_prop_slots
# number_of_prop_unfilled
# TODO:
# only show casting link if all the mapping parts are complete
template::list::create \
    -name ready_templates \
    -multirow ready_templates \
    -no_data "No templates are ready for mapping" \
    -elements {
        pretty_name {
            label "Template"
            orderby upper(w.pretty_name)
        }
        suggested_duration {
            label "Suggested Duration"
            orderby suggested_duration
        }
        number_of_roles {
            label "Roles"
            orderby number_of_roles
        }
        min_number_of_human_roles {
            label "Min \# of players"
            orderby min_number_of_human_roles
        }
        map {
            link_url_col map_url
            display_template {
                Begin Development
            }
        }    
    }

# TODO: min_number_of_human_roles should take agents into account
db_multirow -extend {map_url} ready_templates select_ready_templates {
select workflow_id,
       suggested_duration,
       pretty_name,
       (select count(*)
        from workflow_roles
        where workflow_id = w.workflow_id) as number_of_roles,
       (select count(*)
        from workflow_roles
        where workflow_id = w.workflow_id) as min_number_of_human_roles
  from sim_simulations ss,
       workflows w
 where ss.simulation_id = w.workflow_id
   and w.object_id = :package_id
   and ready_p = 't'
} {
    set map_url [export_vars -base "map-create" { workflow_id }]

    if { [empty_string_p $suggested_duration] } {
        set suggested_duration "none specified"
    }
}
