ad_page_contract {
    Enroll a user in a simulation and display confirmation or redirect for self-casting if appropriate.

    @author Joel Aufrecht
} {
    workflow_id:integer
}

# We need to identify the user
auth::require_login
set user_id [ad_conn user_id]

simulation::template::get -workflow_id $workflow_id -array simulation

if { ![string equal $simulation(sim_type) "casting_sim"] } {
    ad_return_forbidden "Cannot enroll in simulation" "Simulation \"$simulation(pretty_name)\" is in state $simulation(sim_type) and you cannot enroll in it now. Contact your administrator if you believe this is an error. Thank you!"
    ad_script_abort
}

set user_invited_p [simulation::template::user_invited_p -workflow_id $workflow_id]

# Check that the user has permission to enroll
if { [string equal $simulation(enroll_type) "open"] } {
    # Open simulation - anybody can enroll so the user is authorized

    if { !$user_invited_p } {
        # User not invited - check that we are within the enrollment period
        if { [clock scan $simulation(enroll_start)] > [clock seconds] || [clock scan $simulation(enroll_end)] < [clock seconds] } {
            # We are not in the enrollment period
            ad_return_forbidden "Cannot enroll in simulation" "The enrollment period for simulation \"$simulation(pretty_name)\" is between $simulation(enroll_start) and $simulation(enroll_end) and you cannot enroll at this time. Contact your administrator if you believe this is an error. Thank you!"
            ad_script_abort
        }
    }
} else {
    # Closed enrollment. The user needs to be invited to enroll

    if { !$user_invited_p } {
        acs_user::get -user_id $user_id -array user

        ad_return_forbidden \
                "Cannot enroll in simulation \"$simulation(pretty_name)\"" \
                "<blockquote>
  We are sorry, but simulation \"$simulation(pretty_name)\" is not open to enrollment and you are not invited to join the simulation so you cannot enroll at this time.
</blockquote>"
        ad_script_abort        
    }
}

# The user is allowed to enroll, so go ahead
simulation::template::enroll_user \
    -workflow_id $workflow_id \
    -user_id $user_id    

# If there are casting decisions open to the user, redirect to the casting page (casting_type group or open)
if { [string equal $simulation(casting_type) "auto"] } {
    # Auto casting
    # The user will be automatically cast right before the simulation starts
} else {
    # Open or group casting, redirect to casting page
    ad_returnredirect [export_vars -base cast { workflow_id }]    
    ad_script_abort
}

set page_title "You have been enrolled in simulation \"$simulation(pretty_name)\""
set context [list [list "." "SimPlay"] $page_title]
