ad_page_contract {
    This page shows all tasks that an admin has in a certain simulation and
    allows the admin to take action on the tasks in bulk.

    @author Peter Marklund
} {
    workflow_id:integer
    role_id:optional
}

permission::require_permission -object_id [ad_conn package_id] -privilege sim_adminplayer

simulation::template::get -workflow_id $workflow_id -array simulation

set page_title "Your Tasks in Simulation $simulation(pretty_name)"
set context [list [list . "SimPlay"] $page_title]
