simulation::include_contract {
    A list of all roles associated with the Simulation Template

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    workflow_id {}
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

#-------------------------------------------------------------
# roles list 
#-------------------------------------------------------------

if { $display_mode == "edit"} {
    set actions [list "Add a Role" [export_vars -base role-edit {workflow_id} ]]
} else {
    set actions ""
}

template::list::create \
    -name roles \
    -multirow roles \
    -no_data "No roles in this Simulation Template" \
    -actions $actions \
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
            display_col pretty_name
        }
        delete {
            sub_class narrow
            display_template {
                <a href="@roles.delete_url@" onclick="return confirm('Are you sure you want to delete role @roles.pretty_name@?');">
                  <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Edit">
                </a>
            }
        }
    }
#-------------------------------------------------------------
# roles db_multirow
#-------------------------------------------------------------
set return_url "[ad_conn url]?[ad_conn query]"
db_multirow -extend { edit_url char_url delete_url } roles select_roles "
    select wr.role_id,
           wr.pretty_name,
           wr.sort_order
      from workflow_roles wr
     where wr.workflow_id = :workflow_id
     order by lower(pretty_name)
" {
    set edit_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/role-edit" { role_id }]
    set delete_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/role-delete" { role_id return_url }]
}
