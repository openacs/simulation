ad_library {
    Procedures for auto-testing simulation

    @author Joel Aufrecht
    @creation-date 27 October 2002
}

set name [ad_generate_random_string]

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
            # Requiring a simulation package at /simulation
            # TODO: this is restrictive, can we improve?
            array set simulation_node [site_node::get_from_url -url "/simulation"]
            set package_id $simulation_node(package_id)

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
            set item_id [bcms::item::create_item \
                         -item_id $item_id \
                         -item_name "__temporary_test_item__" \
                         -parent_id $parent_id \
                         -content_type $content_type \
                         -storage_type "text"]
            set revision_id [bcms::revision::add_revision \
                                 -item_id $item_id \
                                 -title "__Temporary test item"]
            bcms::revision::set_revision_status \
                -revision_id $revision_id \
                -status "live"
            # TODO: how do I set this through a Tcl API?
            db_dml set_on_map_p {
                update sim_locations
                set on_map_p = 't'
                where home_id = :revision_id
            }

            # Re-generate file
            array unset result
            array set result [simulation::object::xml::generate_file -package_id $package_id]

            # Check return values
            aa_equals "should write file after change" $result(wrote_file_p) "1"
            aa_equals "should not return errors when writing after change" $result(errors) ""

            # Reset the file_path parameter value
            parameter::set_value \
                -package_id $package_id \
                -parameter [simulation::object::xml::file_path_param_name] \
                -value $old_file_path
            
            # Remove the test file
            file delete -force $test_file_path
        }
}
