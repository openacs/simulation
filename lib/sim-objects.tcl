simulation::include_contract {
    Displays a list of simulation objects for the current simulation package instance.

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    display_mode {
        allowed_values {edit display}
        default_value display
    }
    orderby {
        required_p 0
    }
    type {
        required_p 0
    }
    size {
        allowed_values {short long}
        default_value long
    }
}

######################################################################
# Set general variables

set package_id [ad_conn package_id]

if { ![exists_and_not_null user_id] } {
    set user_id [auth::get_user_id]
}

set create_p [permission::permission_p -object_id $package_id -privilege sim_object_create]
set write_p [permission::permission_p -object_id $package_id -privilege sim_object_write]


######################################################################
#
# objects list 
#
######################################################################

#---------------------------------------------------------------------
# Set up supporting variables for list

set add_url [export_vars -base "[ad_conn package_url]citybuild/object-edit" { parent_id }]

if { $create_p } {
    set actions "{Add an object} $add_url"
} else {
    set actions ""
}
if { ![exists_and_not_null parent_id] } {
    set parent_id [bcms::folder::get_id_by_package_id -parent_id 0]
}

if { $size == "yellow-pages"} {
    set filter_sql "and content_type = 'sim_character' or content_type = 'sim_location'
                    and 
"
} else {
    set filter_sql ""
}

#---------------------------------------------------------------------
# Set basic elements list
set elements {
    object_type_pretty {
        label "Type"
        orderby lower(ot.pretty_name)
    }
    title { 
        label "Name"
        orderby r.title
        link_url_col view_url
    }
}

#---------------------------------------------------------------------
# Edit column
# Put an edit link first
if { [string equal $display_mode "edit"] } {
    set elements [concat {
        edit  {
            sub_class narrow
            display_template {
              <if @objects.edit_p@>
                <a href="@objects.edit_url@" title="Edit this object">
                  <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border="0" alt="Edit">
                </a>
              </if>        
            }
        }
    } $elements]
}

#---------------------------------------------------------------------
# Description column
if { [string equal $size "long"] } {
    set elements [concat $elements {        
	description {
	    label "Description"
	    orderby r.description
	}
    }]
}

#---------------------------------------------------------------------
# Delete column
# Put a delete link last
if { [string equal $display_mode "edit"] } {
    set elements [concat $elements {
        delete {
            sub_class narrow
            link_url_col delete_url
            display_template {
               <if @objects.edit_p@ true>
                <a href="@objects.delete_url@" title="Delete this object"
                ><img src="/resources/acs-subsite/Delete16.gif" height="16" 
                width="16" border="0" alt="Edit"></a>
                </if>        
            }
        }
    }]
}

######################################################################
template::list::create \
    -name objects \
    -multirow objects \
    -actions  $actions \
    -elements $elements \
    -orderby {
        default_value title,asc
    }

#---------------------------------------------------------------------
# database query


db_multirow -extend { edit_url view_url delete_url edit_p } objects select_objects "
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
    and    ot.object_type != 'sim_message'
           $filter_sql
    [template::list::orderby_clause -orderby -name "objects"]
" {
    set description [string_truncate -len 200 $description]
    set edit_url [export_vars -base "[apm_package_url_from_id $package_id]citybuild/object-edit" { item_id }]
    set delete_url [export_vars -base "[apm_package_url_from_id $package_id]citybuild/object-delete" { item_id }]
    set edit_p [expr $write_p || [permission::write_permission_p -object_id $item_id]]

    switch -glob $mime_type {
        text/* - {} {
            set view_url [simulation::object::url -name $name]
        }
        default {
            set view_url [simulation::object::content_url -name $name]
        }
    }
}
