ad_page_contract {
    The sim-instantiate wizard

    @author Lars Pind
} {
    workflow_id:integer,notnull
}

permission::require_write_permission -object_id $workflow_id

wizard create siminst -steps {
    1 -label "Roles" -url "map-characters"
    2 -label "Tasks" -url "map-tasks"
    3 -label "Settings" -url "simulation-edit"
    4 -label "Enrollment" -url "simulation-enrollment"
    5 -label "Participants" -url "simulation-participants"
    6 -label "Casting" -url "simulation-casting-3"
} -params {
    workflow_id
}

wizard set_finish_url [export_vars -base "simulation-casting" { workflow_id }]

array set title {
    1 "Assign Roles to Characters"
    2 "Populate Tasks"
    3 "Simulation Settings"
    4 "Define Enrollment"
    5 "Select Participants"
    6 "Define Casting Rules"
}

wizard set_param workflow_id $workflow_id

set state [simulation::template::get_inst_state -workflow_id $workflow_id]

set lowest_available 1
switch $state {
    none {
        set progress 0
    }
    roles_complete {
        set progress 1
    }
    tasks_complete {
        set progress 2
    }
    settings_complete {
        set progress 3
    }
    enrollment_complete {
        set progress 4
    }
    participants_complete {
        set progress 5
    }
    default {
        error "Unknown state: $state"
    }
}

set highest_available [expr $progress + 1]

wizard get_current_step -start $highest_available

set sub_title $title(${wizard:current_id})

workflow::get -workflow_id $workflow_id -array workflow
set page_title "$workflow(pretty_name)"
set context [list [list "." "SimInst"] $page_title]


