ad_page_contract {
    The index page for SimInst
}

set page_title "SimInst"
set context [list $page_title]
set package_id [ad_conn package_id]

######################################################################
#
# avail_templates
#
# A list of templates that can be instantiated
#
######################################################################

#---------------------------------------------------------------------
# avail_templates list
#---------------------------------------------------------------------

set elements {
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
    instantiate {
        link_url_col inst_url
        display_template {
            Start mapping process
        }
    }
}

template::list::create \
    -name avail_templates \
    -multirow avail_templates \
    -no_data "No simulation templates available for instantiation." \
    -elements $elements 

#---------------------------------------------------------------------
# avail_templates multirow
#---------------------------------------------------------------------

# TODO: number_of_roles, min_number_of_human_roles
db_multirow -extend {inst_url} avail_templates select_avail_templates "
select workflow_id,
       suggested_duration,
       pretty_name,
       (select 1) as number_of_roles,
       (select 1) as min_number_of_human_roles
  from sim_simulations ss,
       workflows w
 where ss.simulation_id = w.workflow_id
   and w.object_id = :package_id
   and ready_p = 't'
" {
    set inst_url [export_vars -base "map-characters" { workflow_id }]
}
