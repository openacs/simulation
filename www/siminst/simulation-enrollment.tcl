ad_page_contract {
    Create a new simulation
} {
    workflow_id:integer
}

simulation::template::get -workflow_id $workflow_id -array sim_template

set package_id [ad_conn package_id]

#subsite::get -array closest_subsite    
#set group_admin_url [export_vars -base "${closest_subsite(url)}admin/group-types/one" { { group_type group } }]
#set eligible_groups [simulation::casting_groups -workflow_id $workflow_id]

ad_form -export { workflow_id } -name simulation -form {
    {enroll_type:text(checkbox)
        {label "Enrollment type"}
        {options {{"Allow self-enrollment" closed}}}
            {html {onChange "javascript:acs_FormRefresh('simulation');"}}
        {help_text "If self-enrollment is allowed, this simulation will be publicly listed on the Simulation home page and anybody can enroll themself."}
    }
    {enroll_start:date,to_sql(ansi),from_sql(ansi),optional
        {label "Enrollment start date"}
    }
    {enroll_end:date,to_sql(ansi),from_sql(ansi),optional
        {label "Enrollment end date"}
    }
} -on_request {

    foreach elm { 
        enroll_type
        enroll_start
        enroll_end
    } { 
        set $elm $sim_template($elm)
    }

#    set auto_enroll [simulation::template::get_parties -workflow_id $workflow_id -rel_type auto_enroll]

    # Default values
    set one_month [expr 3600*24*31]

    # TODO: provide more sensible default dates?
    if { [empty_string_p $enroll_start] } {
        set enroll_start [clock format [expr [clock seconds] + 1*$one_month] -format "%Y-%m-%d"]
    }
    if { [empty_string_p $enroll_end] } {
        set enroll_end [clock format [expr [clock seconds] + 2*$one_month] -format "%Y-%m-%d"]
    }
    if { [empty_string_p $enroll_type] } {
        set enroll_type "closed"
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
    foreach elm { enroll_start enroll_end enroll_type } {
        set row($elm) [set $elm]
    }
    
    simulation::template::edit \
        -workflow_id $workflow_id \
        -array row

    wizard forward
}

wizard submit simulation -buttons { back next }
