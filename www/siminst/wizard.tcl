ad_page_contract {
    The sim-instantiate wizard

    @author Lars Pind
} {
    workflow_id:integer,notnull
}

permission::require_write_permission -object_id $workflow_id

wizard create siminst \
    -steps {
        1 -label "Settings" -url "simulation-edit"
        2 -label "Roles" -url "map-characters"
        3 -label "Tasks" -url "map-tasks"
        4 -label "Participants" -url "simulation-participants"
        5 -label "Casting" -url "simulation-casting-3"
    } -params {
        workflow_id
    }

wizard set_finish_url [export_vars -base "simulation-casting" { workflow_id }]

array set title {
    1 "Simulation Settings"
    2 "Assign Characters to Roles"
    3 "Populate Tasks"
    4 "Select Participants"
    5 "Define Casting Rules"
}

wizard set_param workflow_id $workflow_id

set lowest_available 1
set highest_available 5

wizard get_current_step -start $highest_available

set sub_title $title(${wizard:current_id})

workflow::get -workflow_id $workflow_id -array workflow
set page_title "$workflow(pretty_name)"
set context [list [list "." "SimInst"] $page_title]

array set tab_complete_p [simulation::template::get_inst_state -workflow_id $workflow_id]

multirow extend wizard complete_p

multirow create test_multi col1 col2 col3

multirow -local foreach wizard {
    set complete_p $tab_complete_p($url)
}
