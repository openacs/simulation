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

# TODO: verify that prepopulated values work correctly

# TODO: provide more sensible default dates?
# Notification send could be start date minus some parameter
set in_a_month_date [clock format [expr [clock seconds] + 3600*24*31] -format "%Y-%m-%d"]
set in_two_months_date [clock format [expr [clock seconds] + 2*3600*24*31] -format "%Y-%m-%d"]
set in_two_and_a_half_months_date [clock format [expr [clock seconds] + 3*3600*24*31 - 3600*24*15] -format "%Y-%m-%d"]
set in_three_months_date [clock format [expr [clock seconds] + 3*3600*24*31] -format "%Y-%m-%d"]
set in_four_months_date [clock format [expr [clock seconds] + 4*3600*24*31] -format "%Y-%m-%d"]

set eligible_groups [simulation::casting_groups -workflow_id $workflow_id]

ad_form -export { workflow_id } -name simulation -form {
    {enroll_type:text(radio)
        {label "Enrollment type"}
        {options {{"By invitation only" closed} {Open open}}}
            {html {onChange "javascript:FormRefresh('simulation');"}}
    }
    {enroll_start:date,to_sql(ansi),from_sql(ansi),optional
        {label "Enrollment start date"}
    }
    {enroll_end:date,to_sql(ansi),from_sql(ansi),optional
        {label "Enrollment end date"}
    }
    {send_start_note_date:date,to_sql(ansi),from_sql(ansi),optional
        {label "Date to send start notification (mockup only)"}
    }
    {case_start:date,to_sql(ansi),from_sql(ansi),optional
        {label "Simulation start date"}
    }
    {case_end:date,to_sql(ansi),from_sql(ansi),optional
        {label "Simulation end date"}
    }
    {casting_type:text(radio)
        {label "Casting type"}
        {options {{Automatic auto} {Group group} {Open open}}}
    }
    {auto_enroll:integer(checkbox),multiple,optional
        {label "Enroll all users in these groups"}
        {options $eligible_groups}
        {help_text {Use <a href="$group_admin_url">Group Administration</a> to add groups}}
    }    
    {invite_groups:integer(checkbox),multiple,optional
        {label "Invite all users in these groups (mockup only)"}
        {options $eligible_groups}
        {help_text {Use <a href="$group_admin_url">Group Administration</a> to add groups}}
    }    
} -on_request {

    foreach elm { 
        enroll_type
        casting_type
        enroll_start
        enroll_end
        case_start
        case_end
        send_start_note_date 
    } { 
        set $elm $sim_template($elm)
    }

    set auto_enroll [simulation::template::get_parties -workflow_id $workflow_id -rel_type auto_enroll]

    # Default values
    if { [empty_string_p $enroll_start] } {
        set enroll_start $in_a_month_date
    }
    if { [empty_string_p $enroll_end] } {
        set enroll_end $in_two_months_date
    }
    if { [empty_string_p $send_start_note_date] } {
        set send_start_note_date $in_two_and_a_half_months_date
    }
    if { [empty_string_p $case_start] } {
        set case_start $in_three_months_date
    }
    if { [empty_string_p $case_end] } {
        set case_end $in_three_months_date
    }
    if { [empty_string_p $enroll_type] } {
        set enroll_type "closed"
    }
    if { [empty_string_p $casting_type] } {
        set casting_type "auto"
    }

    if { [string equal $enroll_type "closed"] } {
        element set_properties simulation enroll_start -widget hidden
        element set_properties simulation enroll_end -widget hidden
    }

} -on_refresh {

    if { [string equal $enroll_type "closed"] } {
        element set_properties simulation enroll_start -widget hidden
        element set_properties simulation enroll_end -widget hidden
    } else {
        element set_properties simulation enroll_start -widget date
        element set_properties simulation enroll_end -widget date
    }

} -on_submit {
    foreach elm { enroll_start enroll_end send_start_note_date case_start case_end enroll_type casting_type auto_enroll } {
        set row($elm) [set $elm]
    }
    
    # TODO: add invite_gropus to list of elements above

    simulation::template::edit \
        -workflow_id $workflow_id \
        -array row

    ad_returnredirect .
    ad_script_abort
}
