ad_library {
    API for Simulation objects.

    @author Peter Marklund
    @creation-date 2003-11-07
    @cvs-id $Id$
}

namespace eval simulation::object {}

ad_proc -public simulation::object::schedule_generate_xml_file {
    {-package_id ""}
} {
    <p>
      Schedules the proc simulation::object::generate_xml_file to be
      executed now in its own thread.
    </p>

    <p>
      This proc needs to be invoked upon the create, edit, and delete
      event for simulation objects that have the on_map_p attribute
      set to true. It also needs to be invoked if the on_map_p attribute
      is toggled from false to true for a sim object.
    </p>

    

    @author Peter Marklund
} {
    if { [empty_string_p $package_id] } {
        set package_id [ad_conn package_id]
    }

    ad_schedule_proc -thread t -once t 0 simulation::object::generate_xml_file -package_id $package_id
}

ad_proc -public simulation::object::generate_xml_file {
    {-package_id:required}
} {
    <p>
      Re-generates (or generates for the first time) the XML file
      containing information about all simulation objects that are
      to be on the SIMBUILD flash map.
    </p>

    @author Peter Marklund
} {
    ##########
    # Get data to be written to file
    ##########

    # Get a list of names of tables storing the on_map_p attribute for
    # items created in the given package
    set parent_id [bcms::folder::get_id_by_package_id -parent_id 0]
    set sim_table_lists [db_list select_sim_tables {
        select aot.table_name,
               aot.id_column
        from acs_object_types aot,
             acs_attributes aa
        where aot.object_type = aa.object_type
          and aa.attribute_name = 'on_map_p'
          and exists (select 1
                      from cr_items ci
                      where ci.parent_id = :parent_id
                        and ci.content_type = aot.object_type
                     )
    }]

    foreach sim_table $sim_table_list {        
        set table_name [lindex $sim_table 0]
        set id_column [lindex $sim_table 1]

        set object_lists [db_list_of_lists select_on_map_objects "
            select ci.item_id,
                   cr.content_type
                   cr.title,
                   ci.name,
                   cr.description,
            from cr_items ci
                 cr_revisions cr
                 $table_name st           
            where st.on_map_p = 't'
              and st.$id_column = ci.item_id
              and ci.live_revision = cr.revision_id
              and ci.parent_id = :parent_id
        "]
    }

    ##########
    # Generate XML document
    ##########

    set xml_doc "<?xml version=\"1.0\"?>
<objects>"
    foreach object_list $object_lists {
        append xml_doc [generate_xml \
                            -item_id [lindex $object_list 0] \
                            -content_type [lindex $object_list 1] \
                            -title [lindex $object_list 2] \
                            -name [lindex $object_list 3] \
                            -description [lindex $object_list 4]]
    }
    append xml_doc "</objects>"

    ##########
    # Write to file
    ##########

    # TODO: make filepath a parameter
    set file_path "/tmp/map-objects.xml"
    set file_id [open $file_path w]
    puts $file_id $xml_doc
    close $catalog_file_id       
}

ad_proc -public simulation::object::generate_xml {
    {-item_id:required}
    {-content_type ""}
    {-title ""}
    {-name ""}
    {-description ""}
} {
    <p>
      Generate XML to be used by the CityBuild flash map for a certain
      simulation object. Requires there to be an HTTP connection as it
      uses ad_conn package_url to get the URL of the object.
    </p>

    @param item_id    Stored in cr_items.item_id
    @param content_type Stored in cr_items.content_type
    @param title         Stored in cr_revisions.title
    @param name          Stored in cr_items.name
    @param description  Stored in cr_revisions.description
    
    @author Peter Marklund
} {
    # Set default values for optional args
    set optional_args {content_type title name description} 
    foreach arg_name $optional_args {
        if { [empty_string_p [set $arg_name]] } {
            if { ![info exists item_info] } {
                array set item_info [bcms::item::get_item -item_id $item_id -revision live]               
            }
            
            set $arg_name $item_info($arg_name)
        }
    }

    # Get object url and thumbnail url
    set full_package_url "[ad_url]/[ad_conn package_url]"
    set url "$full_package_url/object/$name"
    if { [lsearch -exact {sim_location sim_prop sim_character} $content_type] != -1 } {
        set thumbnail_list [bcms::item::list_related_items \
                            -return_list \
                            -item_id $item_id \
                            -relation_tag thumbnail]
        set thumbnail_uri [lindex [lindex $thumbnail_list 0] 1]
        set thumbnail_url "$full_package_url/object-content/$thumbnail_uri"        
    } else {
        set thumbnail_url ""
    }

    # Create XML document
    append flash_xml "<object>
  <id>$item_id</id>
  <name>[ad_quotehtml $name]</name>
  <url>[ad_quotehtml $url]</url>
  <thumbnail_url>[ad_quotehtml $thumbnail_url]</thumbnail_url>
  <description>[ad_quotehtml $description]</description>
</object>"

    return $flash_xml
}
