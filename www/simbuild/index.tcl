ad_page_contract {
    List workflows designated as templates (but not simulations or cases) in this package.
}

set page_title "SimBuild"
set context [list $page_title]
set package_id [ad_conn package_id]

permission::require_permission -object_id $package_id -privilege sim_template_read
