simulation::include_contract {
    Displays a grouped list of simulation objects for the current simulation package instance.

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    sog_orderby { required_p 0 }
}

######################################################################
# Set general variables

set package_id [ad_conn package_id]
set user_id [auth::get_user_id]
set base_url [apm_package_url_from_id $package_id]
set create_p [permission::permission_p -object_id $package_id -privilege sim_object_create]

if { ![exists_and_not_null parent_id] } {
    set parent_id [bcms::folder::get_id_by_package_id -parent_id 0]
}


######################################################################
#
# objects list 
#
######################################################################

#---------------------------------------------------------------------
# Set up supporting variables for list

set add_url [export_vars -base "[ad_conn package_url]citybuild/object-edit" { parent_id }]

if { $create_p } {
    set actions "{[_ simulation.Add_an_object]} $add_url"
} else {
    set actions ""
}

#---------------------------------------------------------------------
# Set basic elements list
set elements {
    pretty_name {
        label "[_ simulation.Type]"
        orderby upper(ot.pretty_name)
    }
    count { 
        label "[_ simulation.Number]"
        orderby count
    }
}

######################################################################
template::list::create \
    -name objects \
    -multirow objects \
    -actions  $actions \
    -orderby_name sog_orderby \
    -elements $elements 

#---------------------------------------------------------------------
# database query

db_multirow objects select_objects "
    select ot.pretty_name,
           count(*) 
      from cr_folders f,
           cr_items i,
           acs_object_types ot
     where f.package_id = :package_id
       and i.parent_id = f.folder_id
       and ot.object_type = i.content_type
     group by ot.pretty_name
    [template::list::orderby_clause -orderby -name "objects"]
"
