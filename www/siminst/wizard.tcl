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

wizard get_current_step

array set title {
    1 "Assign Roles to Characters"
    2 "Populate Tasks"
    3 "Define Casting"
    4 "Assign Groups to Roles"
}
set sub_title $title(${wizard:current_id})


simulation::template::get -workflow_id $workflow_id -array sim_template
set page_title "$sim_template(pretty_name)"
set context [list [list "." "SimInst"] $page_title]

