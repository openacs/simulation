ad_page_contract {
    Edit a simulation in casting mode
} {
    workflow_id:integer
}

# Redirect to next casting page if the template is ready for casting
if { [simulation::template::ready_for_casting_p -workflow_id $workflow_id] } {

    set simulation(sim_type) casting_sim
    simulation::template::edit -workflow_id $workflow_id -array simulation

    ad_returnredirect [export_vars -base "simulation-casting-2" { workflow_id }]
}

simulation::template::get -workflow_id $workflow_id -array simulation

set page_title "Template \"$simulation(pretty_name)\" not ready for casting"
set context [list [list "." "SimInst"] $page_title]
set package_id [ad_conn package_id]
