ad_page_contract {
    List workflows designated as templates (but not simulations or cases) on this system.
}
set page_title "Templates"
set context [list $page_title]

template::list::create \
    -name sim_templates \
    -multirow sim_templates \
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
            link_url_col delete_url
            display_template {
                <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Edit">
            }
        }
    }

set package_id [ad_conn package_id]

db_multirow -extend { edit_url view_url delete_url } sim_templates select_sim_templates "
    select w.workflow_id,
           w.pretty_name as name,
           'placeholder' as description,
           a.creation_user as created_by,
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
    [template::list::orderby_clause -orderby -name sim_templates]
" {
    set description [string_truncate -len 200 $description]
    set edit_url [export_vars -base "sim-template-edit?workflow_id=$workflow_id"]
    set view_url [export_vars -base "sim-template-edit?workflow_id=$workflow_id"]
    set delete_url [export_vars -base "sim-template-delete?workflow_id=$workflow_id"]
}
