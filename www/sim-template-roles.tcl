# an includelet 

##############################################################
#
# roles
#
# A list of all roles associated with the Simulation Template
#
##############################################################

# maybe replace this chunk of copied text with an includable template
# which passes in a filter for the workflow_id?


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
# TODO: fix this so it returns rows when it should        
db_multirow -extend { edit_url char_url delete_url } roles select_roles "
    select wr.role_id,
           wr.pretty_name as name,
           wr.sort_order,
           ci.name as char_name
      from workflow_roles wr,
           sim_roles sr,
           cr_items ci
     where wr.workflow_id = :workflow_id
       and sr.role_id = wr.role_id
       and ci.item_id = sr.character_id
    [template::list::orderby_clause -orderby -name "roles"]
" {
    set edit_url [export_vars -base "role-edit" { role_id }]
    set char_url [export_vars -base "object/$char_name"]
    set delete_url [export_vars -base "role-delete" { role_id }]
}
