ad_page_contract {
    Create a new simulation
} {
    workflow_id:integer
}

set page_title "Cast simulation"
set context [list [list "." "SimInst"] $page_title]
set package_id [ad_conn package_id]


# TODO: only one aplication group per package - need different solution
set group_id [application_group::group_id_from_package_id -package_id $package_id]
set group_name [group::get_element -group_id $group_id -element group_name]
set group_options [list [list $group_name $group_id]]

# TODO: provide more sensible default dates?
# Notification send could be start date minus some parameter
set in_a_month_date [clock format [expr [clock seconds] + 3600*24*31] -format "%Y %m %d"]
set in_two_months_date [clock format [expr [clock seconds] + 2*3600*24*31] -format "%Y %m %d"]
set in_two_and_a_half_months_date [clock format [expr [clock seconds] + 3*3600*24*31 - 3600*24*15] -format "%Y %m %d"]
set in_three_months_date [clock format [expr [clock seconds] + 3*3600*24*31] -format "%Y %m %d"]
set in_four_months_date [clock format [expr [clock seconds] + 4*3600*24*31] -format "%Y %m %d"]

ad_form -export { workflow_id } -name simulation -form {
    {enroll_start:date,optional
        {label "Enrollment start date"}
        {value $in_a_month_date}
    }
    {enroll_end:date,optional
        {label "Enrollment end date"}
        {value $in_two_months_date}
    }
    {notification_date:date
        {label "Date to send start notification"}
        {value $in_two_and_a_half_months_date}
    }
    {case_start:date
        {label "Simulation start date"}
        {value $in_three_months_date}
    }
    {case_end:date
        {label "Simulation end date"}
        {value $in_four_months_date}
    }
    {enroll_type:text(radio)
        {label "Enrollment type"}
        {options {{Closed closed} {Open closed}}}
        {value closed}
    }
    {casting_type:text(radio)
        {label "Casting type"}
        {options {{Automatic automatic} {Group group} {Open open}}}
        {value automatic}
    }
    {user_group:integer(checkbox),multiple,optional
        {label "Invite all users in these groups"}
        {options $group_options}
        #TODO: this link should use a function to find the subsite path
        {help_text {Use <a href="/admin/groups/?view_by=rel_type">Group Administration</a> to add groups}}
    }    
} -on_submit {
    # Convert dates to ANSI format
    foreach var_name {enroll_start enroll_end notification_date case_start case_end} {
        set ${var_name}_ansi "[lindex [set $var_name] 0]-[lindex [set $var_name] 1]-[lindex [set $var_name] 2]"
    }
    
    simulation::template::instantiate_edit \
        -workflow_id $workflow_id \
        -enroll_start $enroll_start_ansi \
        -enroll_end $enroll_end_ansi \
        -notification_date $notification_date_ansi \
        -case_start $case_start_ansi \
        -case_end $case_end_ansi \
        -enroll_type $enroll_type \
        -casting_type $casting_type \
        -parties $user_group

    # Proceed to 
    ad_returnredirect [export_vars -base "simulation-casting-2" { workflow_id }]
    ad_script_abort
}

