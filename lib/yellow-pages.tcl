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

ad_page_contract {
} {
  search_terms:optional
}


ad_form -name search -form {
    {search_terms:text,optional {label "Restrict to items matching word or phrase"}}
} -validate {
        {search_terms
         {[string length $search_terms] >= 3}
         "\"search_terms\" must be a string containing three or more characters"
        }
} -method GET -on_submit {
    # foobar
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


# Search support
set where_clause(locations) ""
set where_clause(characters) ""
if { [exists_and_not_null search_terms] } {

    set search_columns(locations) {sl.title sl.description cr.content sl.address sl.city sl.history}
    set search_columns(characters) {sc.title sc.description cr.content}

    set where_clause(locations) [simulation::object::search_clause $search_columns(locations) $search_terms]
    set where_clause(characters) [simulation::object::search_clause $search_columns(characters) $search_terms]
}

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
          cr_items ci,
          acs_object_types ot,
          cr_revisions cr
    where sl.in_directory_p = 't'
      and ci.live_revision = sl.revision_id
      and ot.object_type = sl.object_type
      and cr.revision_id = sl.revision_id
      [ad_decode $where_clause(locations) "" "" "and $where_clause(locations)"]
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
          cr_items ci,
          acs_object_types ot,
          cr_revisions cr
    where sc.in_directory_p = 't'
      and ci.live_revision = sc.revision_id
      and ot.object_type = sc.object_type
      and sc.revision_id = cr.revision_id
      [ad_decode $where_clause(characters) "" "" "and $where_clause(characters)"]

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
