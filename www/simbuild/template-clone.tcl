ad_page_contract {
    Create a new simulation
} {
    workflow_id:integer
}

set page_title "Clone a template"

set context [list $page_title]
set package_id [ad_conn package_id]

permission::require_permission -object_id $package_id -privilege sim_template_create
