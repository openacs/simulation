ad_page_contract {
    Create a new simulation
} {
    workflow_id:integer
}

simulation::template::get -workflow_id $workflow_id -array sim_template

set page_title "Cast $sim_template(pretty_name)"
set context [list [list "." "SimInst"] $page_title]
set package_id [ad_conn package_id]

subsite::get -array closest_subsite    
set group_admin_url "${closest_subsite(url)}admin/group-types/one?group_type=group"

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
        {options {{"By invitation only" closed} {Open open}}}
        {value $sim_template(enroll_type)}
    }
    {casting_type:text(radio)
        {label "Casting type"}
        {options {{Automatic auto} {Group group} {Open open}}}
        {value $sim_template(casting_type)}
    }
    {enroll_groups:integer(checkbox),multiple,optional
        {label "Enroll all users in these groups"}
        {options {[simulation::groups_eligible_for_casting]}}
        {help_text {Use <a href="$group_admin_url">Group Administration</a> to add groups}}
    }    
    {invite_groups:integer(checkbox),multiple,optional
        {label "Invite all users in these groups"}
        {options {[simulation::groups_eligible_for_casting]}}
        {help_text {Use <a href="$group_admin_url">Group Administration</a> to add groups}}
    }    
} -on_request {
    
    set enroll_groups [simulation::template::get_parties -workflow_id $workflow_id -rel_type auto-enroll]

} -on_submit {
    # Convert dates to ANSI format
    foreach var_name {enroll_start enroll_end notification_date case_start case_end} {
        set ${var_name}_ansi "[lindex [set $var_name] 0]-[lindex [set $var_name] 1]-[lindex [set $var_name] 2]"
    }
    
    array unset sim_template
    set sim_template(enroll_start) $enroll_start_ansi
    set sim_template(enroll_end) $enroll_end_ansi
    set sim_template(notification_date) $notification_date_ansi
    set sim_template(case_start) $case_start_ansi
    set sim_template(case_end) $case_end_ansi
    set sim_template(enroll_type) $enroll_type
    set sim_template(casting_type) $casting_type
    set sim_template(enroll_groups) $enroll_groups
    set sim_template(invite_gropus) $invite_groups

    simulation::template::edit \
        -workflow_id $workflow_id \
        -array sim_template

    ad_returnredirect .
    ad_script_abort
}
