ad_page_contract {

  @creation-date 2003-10-13
  @cvs-id $Id$
} {
    parent_id:optional
    {orderby "title,asc"}
}

set page_title "Objects"
set context [list $page_title]

if { ![exists_and_not_null parent_id] } {
    set parent_id [bcms::folder::get_id_by_package_id -parent_id 0]
}

template::list::create \
    -name objects \
    -multirow objects \
    -elements {
        edit {
            sub_class narrow
            display_template {
                <a href="@objects.edit_url@"><img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border="0" alt="Edit"></a>
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


set package_id [ad_conn package_id]

db_multirow -extend { edit_url view_url } objects select_objects "
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
    [template::list::orderby_clause -orderby -name "objects"]
" {
    set description [string_truncate -len 200 $description]
    set edit_url [export_vars -base "object-edit" { item_id }]
    set view_url [export_vars -base "object/$name"]
}

set sim_types { sim_character sim_prop sim_home }

db_multirow -extend { create_url label } object_types select_object_types "
    select ot.object_type as content_type,
           ot.pretty_name
    from   acs_object_types ot
    where  ot.object_type in ('[join $sim_types "','"]')
" {
    set create_url [export_vars -base object-edit { content_type parent_id }]
    set label "Create new $pretty_name"

}

#multirow append object_types content_template  "Template" [export_vars -base template-edit] "Upload new Template"
