# an includelet 

##############################################################
#
# sim_objects
#
# A list of all objects associated with the Simulation Template
#
##############################################################

# maybe replace this chunk of copied text with an includable template
# which passes in a filter for the workflow_id?


#-------------------------------------------------------------
# sim_objects list 
#-------------------------------------------------------------

template::list::create \
    -name sim_objects \
    -multirow sim_objects \
    -no_data "No Sim Objects are associated with this Simulation Template" \
    -elements {
        edit {
            sub_class narrow
            link_url_col edit_url
            display_template {
                <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border="0" alt="Edit">
            }
        }
        object_type_pretty {
            label "Type"
            orderby upper(ot.pretty_name)
        }
        title { 
            label "Title"
            orderby r.title
            link_url_col view_url
        }
        description {
            label "Description"
            orderby r.description
        }
    }

db_multirow -extend { edit_url view_url delete_url } sim_objects select_sim_objects "
    select i.item_id,
           i.name,
           r.title,
           r.description,
           i.content_type,
           ot.pretty_name as object_type_pretty
    from   cr_folders f,
           cr_items i,
           cr_revisions r,
           acs_object_types ot,
           sim_workflow_object_map swom
    where  f.package_id = :package_id
    and    i.parent_id = f.folder_id
    and    r.revision_id = i.live_revision
    and    ot.object_type = i.content_type
    and    swom.workflow_id = :workflow_id
    and    swom.object_id = i.item_id

    [template::list::orderby_clause -orderby -name "sim_objects"]
" {
    set description [string_truncate -len 200 $description]
    set edit_url [export_vars -base "object-edit" { item_id }]
    set view_url [export_vars -base "object/$name"]
    set delete_url [export_vars -base "object-delete" { item_id }]
}

set sim_types { sim_character sim_prop sim_location }

db_multirow -extend { create_url label } object_types select_object_types "
    select ot.object_type as content_type,
           ot.pretty_name
    from   acs_object_types ot
    where  ot.object_type in ('[join $sim_types "','"]')
" {
    set create_url [export_vars -base object-edit { content_type parent_id }]
    set label "Create new $pretty_name"
}
