ad_page_contract {

  @creation-date 2003-10-13
  @cvs-id $Id$
} {
} -properties {
}

######################################################################
#
# active_cases
#
# a list of active cases for logged-in user
#
######################################################################

#---------------------------------------------------------------------
# active_cases list
#---------------------------------------------------------------------

template::list::create \
    -name active_cases \
    -multirow active_cases \
    -html {width "100%"}\
    -elements {
	case_name { 
	    label "Case"
	    orderby case_name
	}
	task_count {
	    label "Tasks"
	    orderby task_count
	}
    }

#---------------------------------------------------------------------
# active_cases database query
#---------------------------------------------------------------------
# this is currently a dummy query.  For Phase 2, it should get all cases
# for which the logged-in user has a role, and a count of active tasks
# for that role.

db_multirow active_cases active_cases_select {
    select 'case one' as case_name,
           2 as task_count
}


######################################################################
#
# object_count
#
# A count of all objects in the system, by type, for admins
#
######################################################################

#---------------------------------------------------------------------
# object_count list
#---------------------------------------------------------------------

template::list::create \
    -name object_count \
    -multirow object_count \
    -html {width "100%"} \
    -elements {
        type {
            label "Type"
        }
	count {
	    label "Count"
            link_url_col view_url
        }
    }

#---------------------------------------------------------------------
# object_count database query
#---------------------------------------------------------------------

db_multirow  -extend { view_url } object_count object_count_select "
    select object_type as type,
           count(object_type) as count
      from acs_objects
     where object_type like 'sim_%'
     group by object_type
" {
    set view_url [export_vars -base "object-list" { type }]
}


######################################################################
#
# sim_template_count
#
# A count of all templates, for admins
# They should probably be grouped, but I'm not sure what to group 
# them by yet
#
######################################################################

#---------------------------------------------------------------------
# sim_template_count list
#---------------------------------------------------------------------

template::list::create \
    -name sim_template_count \
    -multirow sim_template_count \
    -html {width "100%"} \
    -elements {
        count {
            label "Simulation Templates"
            link_url_col view_url
        }
    }



template::list::create \
    -name template_count \
    -multirow template_count \
    -elements {
        type {
            label "Type"
        }
	count {
	    label "Count"
            link_url_col view_url
        }
    }

#---------------------------------------------------------------------
# template_count database query
#---------------------------------------------------------------------

db_multirow -extend { view_url } sim_template_count sim_template_count_query "
    select count(workflow_id) as count
      from workflows w
" {
    set view_url [export_vars -base "sim-template-list"]
}
