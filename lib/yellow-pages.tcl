simulation::include_contract {
    Displays a list of simulation objects in the directory for the current simulation package instance.
    This was formerly a mode of the sim-objects includelet but it is different enough to be
    broken out.

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
}

######################################################################
# Set general variables

set package_id [ad_conn package_id]

if { ![exists_and_not_null user_id] } {
    set user_id [auth::get_user_id]
}

######################################################################
#
# objects list 
#
######################################################################

#---------------------------------------------------------------------
# Set basic elements list
set elements {
    object_type {
        label "Type"
        orderby upper(ot.pretty_name)
        display_col object_type_pretty
    }
    title { 
        label "Name"
        orderby r.title
        link_url_col view_url
    }
    description {
        label "Description"
        orderby r.description
    }
}

#---------------------------------------------------------------------
# 
template::list::create \
    -name objects \
    -multirow objects \
    -elements $elements 

#---------------------------------------------------------------------
# database query

db_multirow -extend {view_url} objects select_objects "
   select sl.object_id,
          sl.object_type,
          ot.pretty_name as object_type_pretty,
          sl.title,
          sl.mime_type,
          sl.name,
          sl.item_id,
          sl.description
     from sim_locationsx sl,
          acs_object_types ot
    where in_directory_p = 't'
      and ot.object_type = sl.object_type
   UNION
   select sc.object_id,
          sc.object_type,
          ot.pretty_name as object_type_pretty,
          sc.title,
          sc.mime_type,
          sc.name,
          sc.item_id,
          sc.description
     from sim_charactersx sc,
          acs_object_types ot
    where in_directory_p = 't'
      and ot.object_type = sc.object_type

    [template::list::orderby_clause -orderby -name "objects"]
" {
    set description [string_truncate -len 200 $description]
    switch -glob $mime_type {
        text/* - {} {
           set view_url [simulation::object::url -name $name]
        }
        default {
            set view_url [simulation::object::content_url -name $name]
        }
    }
}
