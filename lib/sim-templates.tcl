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
set add_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/template-edit"]
set create_p [permission::permission_p -object_id $package_id -privilege sim_template_create]

set actions [list "Add a template" $add_url {} \
                 "Load a template" "[apm_package_url_from_id $package_id]simbuild/template-load" {}]

# TODO: make this include honor the display_mode parameter

switch $size {
    short {
        set elements {
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
        set elements {
            edit {
                sub_class narrow
                display_template {
                    <if @sim_templates.edit_p@>
                    <a href="@sim_templates.edit_url@" title="Edit this template">
                    <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border="0" alt="Edit">
                    </a>
                    </if>
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
                display_template {@sim_templates.description;noquote@}
            }
            created_by {
                label "Created by"
                orderby r.createdby
            }
            role_count {
                label "Roles"
            }
            task_count {
                label "Tasks"
            }
            sim_type {
                label "Ready"
                display_eval {[ad_decode $sim_type "ready_template" "Yes" "No"]}
            }
            copy {
                sub_class narrow
                display_template {
                    <img src="/resources/acs-subsite/Copy16.gif" height="16" width="16" border="0" alt="Copy">
                }
                link_url_col clone_url
                link_html { title "Clone this template" }
            }
            delete {
                sub_class narrow
                link_url_col delete_url
                link_html { 
                    title "Delete this template" 
                    onclick  "return confirm('Are you sure you want to delete template @sim_templates.name@?');"
                }
                display_template { 
                    <if @sim_templates.edit_p@>
                    <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Delete">
                    </if>
                }
            }
        }
    }
}

template::list::create \
    -name sim_templates \
    -multirow sim_templates \
    -actions $actions \
    -elements $elements


######################################################################
#
# sim_templates
#
# a list of templates
#
######################################################################

db_multirow -extend { edit_url view_url delete_url clone_url edit_p } sim_templates select_sim_templates "
    select w.workflow_id,
           w.pretty_name as name,
           w.description,
           w.description_mime_type,
           ss.sim_type,
           (select p.first_names || ' ' || p.last_name
              from persons p
             where p.person_id = a.creation_user) as created_by,
           (select count(role_id)
              from workflow_roles
             where workflow_id = w.workflow_id) as role_count,
           (select count(a2.action_id)
              from workflow_actions a2
             where a2.workflow_id = w.workflow_id
               and not exists (select 1
                                 from workflow_initial_action ia2
                                where ia2.workflow_id = w.workflow_id
                                  and ia2.action_id = a2.action_id)) as task_count
      from workflows w, 
           sim_simulations ss,
           acs_objects a
     where w.workflow_id = a.object_id
       and ss.simulation_id = w.workflow_id
       and w.object_id = :package_id 
       and ss.sim_type in ('dev_template','ready_template')
   [template::list::orderby_clause -orderby -name sim_templates]
" {
    set description [ad_html_text_convert -from $description_mime_type -maxlen 200 -- $description]

    set edit_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/template-edit" {workflow_id} ]

    set view_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/template-edit" {workflow_id} ]

    set clone_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/template-clone" {workflow_id} ]

    set edit_p [permission::write_permission_p -object_id $workflow_id]

    set delete_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/template-delete" {workflow_id} ]

}
