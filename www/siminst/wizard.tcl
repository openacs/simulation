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
    3 -label "Casting" -url "simulation-casting-2"
    4 -label "Groups" -url "simulation-casting-3"
} -params {
    workflow_id
}

wizard set_param workflow_id $workflow_id

set state [simulation::template::get_inst_state -workflow_id $workflow_id]

switch $state {
    none {
        set lowest_available 1
        set progress 0
    }
    roles_complete {
        set lowest_available 1
        set progress 1
    }
    tasks_complete {
        set lowest_available 1
        set progress 2
    }
    casting_begun {
        set lowest_available 3
        set progress 2
    }
}

set highest_available [expr $progress + 1]

wizard get_current_step -start $highest_available

array set title {
    1 "Assign Roles to Characters"
    2 "Populate Tasks"
    3 "Define Casting"
    4 "Assign Groups to Roles"
}
set sub_title $title(${wizard:current_id})

workflow::get -workflow_id $workflow_id -array workflow
set page_title "$workflow(pretty_name)"
set context [list [list "." "SimInst"] $page_title]


