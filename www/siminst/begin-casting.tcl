ad_page_contract {
    Verify that a simulation is ready for casting and, if so, change its type.  If not, show an error page.
} {
    workflow_id:integer
}

set page_title "Not ready for casting"
set context [list [list "." "SimInst"] $page_title]
set package_id [ad_conn package_id]

# Perform the same test as in siminst/index.tcl:
#   if { [string equal $role_empty_count 0] && [string equal $prop_empty_count 0]} {
#     change sim_type to casting_sim
#     ad_returnredirect [export_vars -base "simulation-casting-2" { workflow_id }]
# } else {
#   show an error page with links to the incomplete roles and props
# }

