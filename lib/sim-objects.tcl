simulation::include_contract {
    Displays a list of simulation objects for the current simulation package instance.

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    display_mode {
        allowed_values {edit display display-grouped}
        default_value display
    }
    size {
        allowed_values {short long}
        default_value long
    }
}

set package_id [ad_conn package_id]

if { ![exists_and_not_null parent_id] } {
    set parent_id [bcms::folder::get_id_by_package_id -parent_id 0]
}

set elements {
    object_type_pretty {
        label "Type"
        orderby upper(ot.pretty_name)
    }
    title { 
        label "Name"
        orderby r.title
        link_url_col view_url
    }
}

if { [string equal $display_mode "edit"] } {
    # Put an edit link first
    set elements [concat {
        edit  {
            sub_class narrow
            link_url_col edit_url
            display_template {
                <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border="0" alt="Edit">
            }
        }
    } $elements]
}

if { [string equal $size "long"] } {
    set elements [concat $elements {        
	description {
	    label "Description"
	    orderby r.description
	}
    }]
}

if { [string equal $display_mode "edit"] } {
    # Put a delete link last
    set elements [concat $elements {
        delete {
            sub_class narrow
            link_url_col delete_url
            display_template {
                <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Edit">
            }
        }
    }]
}

template::list::create \
    -name objects \
    -multirow objects \
    -elements $elements 


db_multirow -extend { edit_url view_url delete_url } objects select_objects "
    select i.item_id,
           i.name,
           r.title,
           r.description,
           r.mime_type,
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
    set delete_url [export_vars -base "object-delete" { item_id }]

    switch -glob $mime_type {
        text/* - {} {
            set view_url [simulation::object::url -name $name]
        }
        default {
            set view_url [simulation::object::content_url -name $name]
        }
    }
}

set create_object_url [export_vars -base object-edit { parent_id }]
