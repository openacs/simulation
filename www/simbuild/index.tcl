ad_page_contract {
    List workflows designated as templates (but not simulations or cases) in this package.
} {
    sb_orderby:optional
}

if { ![exists_and_not_null sb_orderby] } {
    set sb_orderby 0
}

set page_title "SimBuild"
set context [list $page_title]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]
set help_url "${package_url}object/[parameter::get -package_id $package_id -parameter SimBuildHelpFile]"

permission::require_permission -object_id $package_id -privilege sim_template_read
