ad_library {
    Procedures for auto-testing simulation

    @author Joel Aufrecht
    @creation-date 27 October 2002
}

set name [ad_generate_random_string]

aa_register_case simulation__data_model {
    Test the simulation::object:url and simulation::object::content_url
    procs.
} {
    aa_log [simulation::object::url -name "test_name"]
    aa_log [simulation::object::url -name "test_name_2" -simplay 1]
    aa_log [simulation::object::content_url -name "test_name"]
}

aa_register_case simulation__data_model {
    Checks that the data model is present.

    @author Joel Aufrecht
    @creation-date 2003-08-13
} {
    aa_run_with_teardown \
        -rollback \
        -test_code {
            # put a record in the system

            set simulation_rowcount [db_string sim_rowcount "
              select count(*)
                from sim_simulations"]

            # see that the record comes back in the option list
            aa_true "sim_simulations exists" [expr $simulation_rowcount >= 0]
        }
}

aa_register_case simulation__generate_xml {
    Tests the simulation::object::xml::generate_file proc.

    @author Peter Marklund
} {
    aa_run_with_teardown \
        -rollback \
        -test_code {
            # Assuming at least one package instance of the simulation package. We
            # pick the instance created first for testing
            set package_id [db_string first_package_id {
                select min(package_id)
                from apm_packages
                where package_key = 'simulation'
            }]

            # Save file_path value
            set old_file_path [simulation::object::xml::file_path $package_id]

            # Set test file path
            set test_file_path "/tmp/test-map.xml"
            parameter::set_value \
                -package_id $package_id \
                -parameter [simulation::object::xml::file_path_param_name] \
                -value $test_file_path

            # Generate file for first time
            array unset result
            array set result [simulation::object::xml::generate_file -package_id $package_id]

            # Check return values
            aa_equals "should write file first time" $result(wrote_file_p) "1"            
            aa_equals "should write file first time with no errors" $result(errors) ""            

            # Re generate file
            array unset result
            array set result [simulation::object::xml::generate_file -package_id $package_id]

            # Check return values
            aa_equals "should not write file without change" $result(wrote_file_p) "0"
            aa_equals "should not return errors when not writing" $result(errors) ""

            # Add a map item
            set item_id [db_nextval acs_object_id_seq]
            set parent_id [bcms::folder::get_id_by_package_id -package_id $package_id]
            set content_type "sim_location"
            set attributes [list [list on_map_p t]]
            set test_item_name "__temporary_test_item__"
            set item_id [bcms::item::create_item \
                         -item_id $item_id \
                         -item_name $test_item_name \
                         -parent_id $parent_id \
                         -content_type $content_type \
                         -storage_type "text"]
            set revision_id [bcms::revision::add_revision \
                                 -item_id $item_id \
                                 -title "__Temporary test item" \
                                 -additional_properties $attributes]
            bcms::revision::set_revision_status \
                -revision_id $revision_id \
                -status "live"

            # Re-generate file
            array unset result
            array set result [simulation::object::xml::generate_file -package_id $package_id]

            # Check return values
            aa_equals "should write file after change" $result(wrote_file_p) "1"
            aa_equals "should not return errors when writing after change" $result(errors) ""

            # Parse the generated file and do some basic checking
            set xml_doc [template::util::read_file $test_file_path]
            set tree [xml_parse -persist $xml_doc]
            set root_node [xml_doc_get_first_node $tree]
            set root_tag_name "objects"
            set object_tag_name "object"
            aa_equals "checking root tag" [xml_node_get_name $root_node] $root_tag_name
            set found_object_p 0
            foreach object_node [xml_node_get_children_by_name $root_node $object_tag_name] {
                set url_content [xml_get_child_node_content_by_path $object_node { url }]
                if { [regexp "$test_item_name\$" $url_content] } {
                    set found_object_p 1
                }
            }
            aa_equals "We found an object with name $test_item_name" $found_object_p 1
            #aa_log "$xml_doc"

            # Reset the file_path parameter value
            parameter::set_value \
                -package_id $package_id \
                -parameter [simulation::object::xml::file_path_param_name] \
                -value $old_file_path
            
            # Remove the test file
            file delete -force $test_file_path
        }
}
