
simulation::template::get -workflow_id $workflow_id -array simulation

set pretty_name "Clone of $simulation(pretty_name)"

ad_form -name clone -export { workflow_id } -edit_buttons [list [list "Clone" ok]] -form {
    {pretty_name:text
        {label "Name"}
        {html {size 50}}
    }
} -on_request {

} -on_submit {
    set unique_p [simulation::template::pretty_name_unique_p \
                      -package_id [ad_conn package_id] \
                      -pretty_name $pretty_name]
    
    if { !$unique_p } {
        form set_error clone pretty_name "This name is already used by another simulation"
        break
    }

    set new_simulation(pretty_name) $pretty_name
    set new_simulation(short_name) {}
    set new_simulation(sim_type) {dev_template}

    switch $simulation(sim_type) {
        "dev_template" - "ready_template" {
            set new_simulation(sim_type) "dev_template"
        }
        "dev_sim" {
            set new_simulation(sim_type) "dev_sim"
        }
        default {
            error "Cloning of template with sim_type=$simulation(sim_type) not supported"
        }
    }
    
    simulation::template::clone \
        -workflow_id $workflow_id \
        -package_key "simulation" \
        -object_id [ad_conn package_id] \
        -array new_simulation

    ad_returnredirect .
    ad_script_abort
}
