ad_page_contract {
    Create a new simulation
} {
    workflow_id:integer
}

simulation::template::get -workflow_id $workflow_id -array sim_template

ad_form -export { workflow_id } -name simulation -form {
    {pretty_name:text
        {label "Simulation Name"}
        {html {size 40}}
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
} -on_request {

    foreach elm { 
        send_start_note_date 
        case_start
        case_end
        pretty_name
    } { 
        set $elm $sim_template($elm)
    }

    # Default values
    set one_month [expr 3600*24*31]

    # TODO: provide more sensible default dates?
    if { [empty_string_p $send_start_note_date] } {
        set send_start_note_date [clock format [expr [clock seconds] + 2*$one_month] -format "%Y-%m-%d"]
    }
    if { [empty_string_p $case_start] } {
        set case_start [clock format [expr [clock seconds] + 3*$one_month] -format "%Y-%m-%d"]
    }
    if { [empty_string_p $case_end] } {
        set case_end [clock format [expr [clock seconds] + 4*$one_month] -format "%Y-%m-%d"]
    }
} -on_submit {
    foreach elm { send_start_note_date case_start case_end pretty_name } {
        set row($elm) [set $elm]
    }
    
    simulation::template::edit \
        -workflow_id $workflow_id \
        -array row

    wizard forward
}

wizard submit simulation -buttons { back next }

