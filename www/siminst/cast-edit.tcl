ad_page_contract {
    Create/edit a simulation
} {
    workflow_id:integer
}

set page_title "Create/edit simulation"
set context [list $page_title]
set package_id [ad_conn package_id]

ad_form -export { workflow_id } -name simulation \
    -form {
        {enroll_start 
            {label "Enrollment start date"}
        }
        {enroll_end 
            {label "Enrollment end date"}
        }
        {notification_date
            {label "Date to send start notification"}
        }
        {case_start 
            {label "Simulation start date"}
        }
        {case_end
            {label "Simulation end date"}
        }
        {enroll_type
            {label "Open Enrollment?"}
        }
        {casting_type
            {label "Open casting?"}
        }
        {tools
            {label "tools for enrollment and casting. (upload of user list csv, ... others?) TODO..."}
        }    
    } -on_submit {
        # TODO (clone the template and create a new simulation record)
        ad_returnredirect simulation-casting
        ad_script_abort
    }
