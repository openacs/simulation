simulation::include_contract {
    Displays a list of templates for the current simulation package instance.

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    display_mode {
        allowed_values {edit display}
        default_value display
    }
    size {
        allowed_values {short long}
        default_value long
    }
}

set package_id [ad_conn package_id]

# TODO: make this include honor the display_mode parameter

switch $size {
    short {
	template::list::create \
	    -name sim_templates \
	    -multirow sim_templates \
	    -actions { "Add a template" sim-template-edit } \
	    -elements {
		name {
		    label "Template"
		    link_url_col edit_url
		    orderby upper(ot.pretty_name)
		}
		role_count {
		    label "Roles"
		}
		task_count {
		    label "Tasks"
		}
	    }
    }
    default { 
	template::list::create \
	    -name sim_templates \
	    -multirow sim_templates \
	    -actions { "Add a template" sim-template-edit } \
	    -elements {
		edit {
		    sub_class narrow
		    link_url_col edit_url
		    display_template {
			<img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border="0" alt="Edit">
		    }
		}
		name {
		    label "Name"
		    orderby upper(ot.pretty_name)
		    link_url_col view_url
		}
		description {
		    label "Description"
		    orderby r.description
		}
		created_by {
		    label "Created by"
		    orderby r.createdby
		}
		object_count {
		    label "Objects"
		}
		role_count {
		    label "Roles"
		}
		task_count {
		    label "Tasks"
		}
		delete {
		    sub_class narrow
		    display_template {
			<a href="@sim_templates.delete_url@" 
                           onclick="return confirm('Are you sure you want to delete template @sim_templates.name@?');">
                          <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Delete">
                        </a>
		    }
		}
	    }
    }
}


######################################################################
#
# sim_templates
#
# a list of templates
#
######################################################################

db_multirow -extend { edit_url view_url delete_url } sim_templates select_sim_templates "
    select w.workflow_id,
           w.pretty_name as name,
           'placeholder' as description,
           (select p.first_names || ' ' || p.last_name
              from persons p
             where p.person_id = a.creation_user) as created_by,
           (select count(object_id)
              from sim_workflow_object_map
             where workflow_id = w.workflow_id) as object_count,
           (select count(role_id)
              from workflow_roles
             where workflow_id = w.workflow_id) as role_count,
           (select count(action_id)
              from workflow_actions
             where workflow_id = w.workflow_id) as task_count
      from workflows w, acs_objects a
     where w.workflow_id = a.object_id
       and w.object_id = :package_id 
   [template::list::orderby_clause -orderby -name sim_templates]
" {
    set description [string_truncate -len 200 $description]
    set edit_url [export_vars -base "sim-template-edit?workflow_id=$workflow_id"]
    set view_url [export_vars -base "sim-template-edit?workflow_id=$workflow_id"]
    set delete_url [export_vars -base "sim-template-delete?workflow_id=$workflow_id"]
}
