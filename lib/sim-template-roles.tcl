simulation::include_contract {
    A list of all roles associated with the Simulation Template

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    workflow_id {}
}

set package_id [ad_conn package_id]

#-------------------------------------------------------------
# roles list 
#-------------------------------------------------------------

template::list::create \
    -name roles \
    -multirow roles \
    -no_data "No roles in this Simulation Template" \
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
        }
        char_name {
            label "Character"
            link_url_col char_url
        }
        delete {
            sub_class narrow
            link_url_col delete_url
            display_template {
                <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Edit">
            }
        }
    }
#-------------------------------------------------------------
# roles db_multirow
#-------------------------------------------------------------
set return_url "[ad_conn url]?[ad_conn query]"
db_multirow -extend { edit_url char_url delete_url } roles select_roles "
    select wr.role_id,
           wr.pretty_name as name,
           wr.sort_order,
           cr.title as char_name
      from workflow_roles wr,
           sim_roles sr,
           cr_items ci,
           cr_revisions cr
     where wr.workflow_id = :workflow_id
       and sr.role_id = wr.role_id
       and ci.item_id = sr.character_id
       and cr.revision_id = ci.live_revision
    [template::list::orderby_clause -orderby -name "roles"]
" {
    set edit_url [export_vars -base "role-edit" { role_id }]
    set char_url [export_vars -base "object/$char_name"]
    set delete_url [export_vars -base "role-delete" { role_id return_url }]
}
