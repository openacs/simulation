ad_page_contract {
    Script that starts the casting of a simulation template
    by setting sim_type to casting_sim. Will check that the template
    is ready for casting and issue a message to the user if it's not.

    @author Peter Marklund
} {
    workflow_id:integer
    {return_url "."}
}

# Redirect to next casting page if the template is ready for casting
if { [simulation::template::ready_for_casting_p -workflow_id $workflow_id] } {

    set simulation(sim_type) casting_sim
    simulation::template::edit -workflow_id $workflow_id -array simulation

    ad_returnredirect $return_url
}

simulation::template::get -workflow_id $workflow_id -array simulation

set page_title "Template \"$simulation(pretty_name)\" not ready for casting"
set context [list [list "." "SimInst"] $page_title]
set package_id [ad_conn package_id]
