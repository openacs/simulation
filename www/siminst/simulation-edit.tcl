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
    {enroll_type:text(radio)
        {label "Allow Self Enrollment"}
        {options {{"Yes" open} {"No" closed}}}
            {html {onChange "javascript:acs_FormRefresh('simulation');"}}
        {help_text "If self-enrollment is allowed, this simulation will be publicly listed on the Simulation home page and anybody can enroll themself."}
    }
    {enroll_start:date,to_sql(ansi),from_sql(ansi),optional
        {label "Enrollment start date"}
    }
    {enroll_end:date,to_sql(ansi),from_sql(ansi),optional
        {label "Enrollment end date"}
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
        enroll_type
        enroll_start
        enroll_end
    } { 
        set $elm $sim_template($elm)
    }

    set description [template::util::richtext::create $sim_template(description) $sim_template(description_mime_type)]

    if { ![exists_and_not_null sim_template(enroll_type)] } {
        set enroll_type closed
    }

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
    # TODO: B: (0.5h) Offer sensible defaults for enroll_start and enroll_end. 
    # Couldn't get it to work in the on_refresh block. Lars?
    if { [empty_string_p $enroll_start] } {
        set enroll_start [clock format [expr [clock seconds] + 1*$one_week] -format "%Y-%m-%d"]
    }
    if { [empty_string_p $enroll_end] } {
        set enroll_end [clock format [expr [clock seconds] + 2*$one_week + $default_duration] -format "%Y-%m-%d"]
    }

} -on_submit {

    # Date validation
    set error_p 0
    # All dates need to be in the future
    set dates_to_check {send_start_note_date case_start case_end}
    if { [string equal $enroll_type "open"] } {
        lappend dates_to_check enroll_start enroll_end
    }
    foreach date_var $dates_to_check {
        if { [clock scan [set $date_var]] < [clock seconds] } {
            template::form::set_error simulation $date_var "The date needs to be in the future"
            set error_p 1                            
        }        
    }

    if { [clock scan $send_start_note_date] > [clock scan $case_start] } {
        template::form::set_error simulation send_start_note_date "Send start note date must be before simulation start date"
        set error_p 1                            
    }
    if { [clock scan $case_start] > [clock scan $case_end] } {
        template::form::set_error simulation case_start "Simulation start date must be before simulation end date"
        set error_p 1                            
    }
    if { [string equal $enroll_type "open"] } {
        if { [empty_string_p $enroll_start] } {
            template::form::set_error simulation enroll_start "When self enrollment is allowed you need to specify an enrollment start date"
            set error_p 1                            
        }
        if { [empty_string_p $enroll_end] } {
            template::form::set_error simulation enroll_end "When self enrollment is allowed you need to specify an enrollment end date"
            set error_p 1                            
        }

        if { [clock scan $enroll_start] > [clock scan $case_start] } {
            template::form::set_error simulation enroll_start "Enrollment start date must be before simulation start date"
            set error_p 1                            
        }
        if { [clock scan $enroll_end] > [clock scan $case_start] } {
            template::form::set_error simulation enroll_end "Enrollment end date must be before simulation start date"
            set error_p 1                            
        }
        if { [clock scan $enroll_start] > [clock scan $enroll_end] } {
            template::form::set_error simulation enroll_start "Enrollment start date must be before enrollment end date"
            set error_p 1                            
        }
    }
    if { $error_p } {
        break
    }

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

    foreach elm { send_start_note_date case_start case_end pretty_name description description_mime_type enroll_type enroll_start enroll_end } {
        set row($elm) [set $elm]
    }
 
    simulation::template::edit \
        -workflow_id $workflow_id \
        -array row

    simulation::template::flush_inst_state -workflow_id $workflow_id
    wizard forward
}

# Want this to be executed both on_refresh and on_request
if { [string equal $enroll_type "closed"] } {
    element set_properties simulation enroll_start -widget hidden
    element set_properties simulation enroll_end -widget hidden
} else {
    element set_properties simulation enroll_start -widget date
    element set_properties simulation enroll_end -widget date
}    

wizard submit simulation -buttons { back next }
