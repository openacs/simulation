ad_library {
    API for Simulation objects.

    @author Peter Marklund
    @creation-date 2003-11-07
    @cvs-id $Id$
}

namespace eval simulation::object {}
namespace eval simulation::object::xml {}

ad_proc -private simulation::object::xml::file_sweeper {} {
    Loop over all simulation package instances and re-generate
    XML map files for them. 
    
    @see simulation::object::xml::generate_file
    
    @author Peter Marklund
} {
    set simulation_package_ids [db_list simulation_package_ids {
        select package_id
        from apm_packages
        where package_key = 'simulation'
    }]

    ns_log Notice "Proc simulation::object::xml::file_sweeper executing with simulation_package_ids=$simulation_package_ids"
    foreach package_id $simulation_package_ids {
        generate_file -package_id $package_id
    }
    ns_log Notice "Finished executing simulation::object::xml::file_sweeper"
}

ad_proc -private simulation::object::xml::generate_file {
    {-package_id:required}
} {
    Generate map XML document for the package. Compare the XML
    document with any existing XML document for the package and
    write the new document to the filesystem if it differs from
    the existing document. Sends a notification if the file
    was generated or if there were errors generating the file.

    @see simulation::object::xml::get_doc

    @return 1 if a new XML file was written and 0 otherwise

    @author Peter Marklund
} {
    set errors [list]

    set parameter_name "MapXmlFilePath"
    set file_path [parameter::get -parameter $parameter_name -package_id $package_id]

    # An empty file_path signifies that no XML map file should be generated
    if { [empty_string_p $file_path] } {
        return
    }

    # file_path validity check
    set file_path_error_prefix "Parameter simulation.$parameter_name for package $package_id has invalid value \"${file_path}\"."
    if { ![regexp {^/} $file_path] } {
        set error_message "$file_path_error_prefix It needs to start with /"
        lappend errors $error_message
        ns_log Error $error_message
    }
    if { ![file readable $file_path] } {
        set error_message "$file_path_error_prefix The file is not readable"
        lappend errors $error_message
        ns_log Error $error_message        
    }

    set wrote_file_p 0
    with_catch errmsg {

        if { [llength $errors] == 0 } {
            set old_xml_doc [template::util::read_file $file_path]
            set new_xml_doc [get_doc -package_id $package_id]
            set xml_changed_p [ad_decode [string compare $old_xml_doc $new_xml_doc] 0 0 1]
            error hej
            if { $xml_changed_p } {
                template::util::write_file $file_path
                set wrote_file_p 1
            }
        }
    } {
        global errorInfo
        set error_message "Generating XML file failed with error message: $errmsg\n\n$errorInfo"
        ns_log Error $error_message
        lappend errors $error_message
    }

    if { $wrote_file_p || [llength $errors] > 0 } {
        notify \
            -package_id $package_id \
            -file_path $file_path \
            -wrote_file_p $wrote_file_p \
            -errors $errors
    }

    return $wrote_file_p
}

ad_proc -private simulatation::object::xml::notify {
    {-package_id:required}
    {-file_path:required}
    {-wrote_file_p:required}
    {-errors:required}
} {
    Send a notification about the results of an XML file generation.

    @author Peter Marklund
} {
    set package_url "[ad_url][apm_package_url_from_id $package_id]"

    set subject "XML File generation results for package at ${package_url}"

    if { $wrote_file_p } {
        append body "An XML file was written to file at \"$file_path\"."
    } else {
        append body "An XML file could not be written to file at \"$file_path\"."
    }

    if { [llength $errors] > 0 } {
        set all_errors [join $errors "\n\n"]
        append body "\n\nThe following errors were encountered:

$all_errors

"
    }

    # Send notification    
}

ad_proc -private simulation::object::xml::get_doc {
    {-package_id:required}
} {
    Generates XML for all relevant simulation objects in the given
    package (that have on_map_p attribute set to true).

    @return An XML document

    @author Peter Marklund
} {
    set full_package_url "[ad_url][apm_package_url_from_id $package_id]"

    # Get table names and id column names for the on_map_p attribute of each object type
    # By using the multirow we avoid a nested db_foreach
    set parent_id [bcms::folder::get_id_by_package_id -parent_id 0]
    db_multirow -local sim_table_list select_sim_tables {
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
    }

    # Open XML document
    set xml_doc "<?xml version=\"1.0\"?>\n<objects>\n"

    # Object type loop.
    template::multirow -local foreach sim_table_list {
        ns_log Notice "
            select ci.item_id as id,
                   cr.title as name,
                   ci.name as uri,
                   cr.description,
                   ci.content_type,
                   (select min(ci2.name)
                    from cr_item_rels cir,
                         cr_items ci2
                    where cir.item_id = ci.item_id
                      and cir.related_object_id = ci2.item_id
                      and cir.relation_tag = 'thumbnail') as thumbnail_uri
            from cr_items ci
                 left outer join cr_item_rels cir on (cir.item_id = ci.item_id),
                 cr_revisions cr,
                 $table_name st           
            where st.on_map_p = 't'
              and st.$id_column = cr.revision_id
              and ci.live_revision = cr.revision_id
              and ci.parent_id = :parent_id
              order by ci.name
        "
        db_foreach select_on_map_objects "
            select ci.item_id as id,
                   cr.title as name,
                   ci.name as uri,
                   cr.description,
                   ci.content_type,
                   (select min(ci2.name)
                    from cr_item_rels cir,
                         cr_items ci2
                    where cir.item_id = ci.item_id
                      and cir.related_object_id = ci2.item_id
                      and cir.relation_tag = 'thumbnail') as thumbnail_uri
            from cr_items ci
                 left outer join cr_item_rels cir on (cir.item_id = ci.item_id),
                 cr_revisions cr,
                 $table_name st           
            where st.on_map_p = 't'
              and st.$id_column = cr.revision_id
              and ci.live_revision = cr.revision_id
              and ci.parent_id = :parent_id
              order by ci.name
        " {
            set url "$full_package_url/object/$name"

            if { [lsearch -exact {sim_location sim_prop sim_character} $content_type] != -1 } {
                set thumbnail_url "${full_package_url}object-content/${thumbnail_uri}"
            } else {
                set thumbnail_url ""
            }

            append xml_doc "  <object>\n"
            # Assuming var names are identical to XML tag names
            set xml_tag_names {name url thumbnail_url description}
            foreach tag_name $xml_tag_names {
                append xml_doc "    <${tag_name}>[ad_quotehtml [set ${tag_name}]]</${tag_name}>\n"
            }            
            append xml_doc "  </object>\n"

        } ;# End object loop

    } ;# End object type loop

    # Close XML document
    append xml_doc "</objects>\n"

    return $xml_doc
}
