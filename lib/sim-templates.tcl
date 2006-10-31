simulation::include_contract {
    Displays a list of templates for the current simulation package instance.

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    size {
        allowed_values {short long}
        default_value long
    }
    sb_orderby { required_p 0 }
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set add_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/template-edit"]
set create_p [permission::permission_p -object_id $package_id -privilege sim_template_create]
set package_admin_p [permission::permission_p -object_id $package_id -privilege admin]

set actions [list "[_ simulation.Add_a_template]" $add_url {} \
                 "[_ simulation.Import_a_template]" "[apm_package_url_from_id $package_id]simbuild/template-load" {}]

switch $size {
    short {
        set elements {
            name {
                label "[_ simulation.Template]"
                link_url_col edit_url
                orderby upper(w.pretty_name)
            }
            role_count {
                label "[_ simulation.Roles]"
            }
            task_count {
                label "[_ simulation.Tasks]"
            }
        }
    }
    default { 
        set elements {
            edit {
                sub_class narrow
                display_template {
                    <if @sim_templates.edit_p@>
                    <a href="@sim_templates.edit_url@" title="[_ simulation.Edit_this_template]">
                    <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border="0" alt="[_ simulation.Edit]">
                    </a>
                    </if>
                }
            }
            name {
                label "[_ simulation.Template_Name]"
                orderby upper(w.pretty_name)
                link_url_col view_url
            }
            description {
                label "[_ simulation.Description]"
                orderby description
                display_template {@sim_templates.description;noquote@}
            }
            created_by {
                label "[_ simulation.Created_by]"
                orderby created_by
            }
            role_count {
                label "[_ simulation.Roles]"
            }
            task_count {
                label "[_ simulation.Tasks]"
            }
            sim_type {
                label "[_ simulation.Ready]"
                display_eval {[ad_decode $sim_type "ready_template" "Yes" "No"]}
            }
            copy {
                sub_class narrow
                display_template {
                    <img src="/resources/acs-subsite/Copy16.gif" height="16" width="16" border="0" alt="[_ simulation.Copy]">
                }
                link_url_col clone_url
                link_html { title "[_ simulation.Clone_this_template]" }
            }
            delete {
                sub_class narrow
                link_url_col delete_url
                link_html { 
                    title "[_ simulation.Delete_this_template]" 
                    onclick  "return confirm('[_ simulation.lt_Are_you_sure_you_want_2] @sim_templates.name@?');"
                }
                display_template { 
                    <if @sim_templates.edit_p@>
                    <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="[_ simulation.Delete]">
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
    -orderby_name sb_orderby \
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
           w.description as description,
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
             where a2.workflow_id = w.workflow_id) as task_count
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

    set edit_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/template-sim-type-update" { workflow_id { sim_type "dev_template" } }]

    set view_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/template-sim-type-update" { workflow_id { sim_type "dev_template" } }]

    set clone_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/template-clone" { workflow_id }]

    set edit_p [permission::write_permission_p -object_id $workflow_id]

    set delete_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/template-delete" { workflow_id }]

}
