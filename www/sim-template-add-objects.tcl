ad_page_contract {

  @creation-date 2003-10-13
  @cvs-id $Id$
} {
    workflow_id
    {orderby "title,asc"}
    {type:optional}
}

set package_id [ad_conn package_id]

#---------------------------------------------------------------------
# Get information about the workflow
#---------------------------------------------------------------------

workflow::get -workflow_id $workflow_id -array workflow
set page_title "Add Sim Objects to $workflow(pretty_name)"
set context [list [list "sim-template-list" "Sim Templates"] [list "sim-template-edit?workflow_id=$workflow_id" "$workflow(pretty_name)"] $page_title]


######################################################################
#
# sim_objects
#
# A list of objects to add to a chosen workflow
# At the moment, this is all objects
# TODO: add checkbox to allow adding multiple objects in one go
#
######################################################################

#---------------------------------------------------------------------
# sim_objects list
#---------------------------------------------------------------------

template::list::create \
    -name sim_objects \
    -multirow sim_objects \
    -no_data "No unlinked objects" \
    -elements {
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
        add_to_sim_template {
            sub_class narrow
            link_url_col add_to_sim_template_url
            display_template {
                <img src="/resources/acs-subsite/Add16.gif" height="16" width="16" border="0" alt="Add to Template">
            }
        }
    }

#---------------------------------------------------------------------
# sim_objects database query
#---------------------------------------------------------------------

db_multirow -extend { view_url add_to_sim_template_url } sim_objects sim_objects_select "
    select i.item_id,
           i.name,
           r.title,
           r.description,
           i.content_type,
           ot.pretty_name as object_type_pretty
    from   cr_folders f,
           cr_items i,
           cr_revisions r,
           acs_object_types ot
    where  f.package_id = :package_id
    and    i.parent_id = f.folder_id
    and    r.revision_id = i.live_revision
    and    ot.object_type = i.content_type
    and    i.item_id not in (select object_id 
                             from sim_workflow_object_map
                            where workflow_id = :workflow_id)
    [template::list::orderby_clause -orderby -name "sim_objects"]
" {
    set description [string_truncate -len 200 $description]
    set view_url [export_vars -base "object/$name"]
    set add_to_sim_template_url [export_vars -base "sim-template-add-objects-2.tcl" { item_id workflow_id }]
}

#---------------------------------------------------------------------
# Create variables for the adp
#---------------------------------------------------------------------

set create_object_url [export_vars -base "object-edit" { workflow_id } ]