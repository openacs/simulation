ad_page_contract {
    Create a new simulation
} {
    workflow_id:integer
}

permission::require_write_permission -object_id $workflow_id

simulation::template::get -workflow_id $workflow_id -array sim_template

ad_form -export { workflow_id } -name simulation -form {
    {pretty_name:text
        {label "Simulation Name"}
        {html {size 60}}
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
    {description:richtext(richtext),optional
        {label "Description"}
        {html {cols 60 rows 8}}
        {help_text "This description is visible to users during enrollment."}
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

    set description [template::util::richtext::create $sim_template(description) $sim_template(description_mime_type)]

    # Default values
    set one_week [expr 3600*24*7]

    if { ![empty_string_p $sim_template(suggested_duration)] } {
        # TODO: (0.5h) use suggested_duaration_seconds instead here. Need to edit template-procs.xql
        #set default_duration $sim_template(suggested_duration_seconds)
        set default_duration $one_week
    } else {
        set default_duration $one_week
    }

    if { [empty_string_p $send_start_note_date] } {
        set send_start_note_date [clock format [expr [clock seconds] + 1*$one_week] -format "%Y-%m-%d"]
    }
    if { [empty_string_p $case_start] } {
        set case_start [clock format [expr [clock seconds] + 2*$one_week] -format "%Y-%m-%d"]
    }
    if { [empty_string_p $case_end] } {
        set case_end [clock format [expr [clock seconds] + 2*$one_week + $default_duration] -format "%Y-%m-%d"]
    }
} -on_submit {
    set description_mime_type [template::util::richtext::get_property format $description]
    set description [template::util::richtext::get_property contents $description]

    set unique_p [simulation::template::pretty_name_unique_p \
                      -workflow_id $workflow_id \
                      -package_id [ad_conn package_id] \
                      -pretty_name $pretty_name]
    
    if { !$unique_p } {
        form set_error simulation pretty_name "This name is already used by another simulation"
        break
    }

    foreach elm { send_start_note_date case_start case_end pretty_name description description_mime_type } {
        set row($elm) [set $elm]
    }
 
    simulation::template::edit \
        -workflow_id $workflow_id \
        -array row

    wizard forward
}

wizard submit simulation -buttons { back next }

