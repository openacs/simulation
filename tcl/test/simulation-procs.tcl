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
