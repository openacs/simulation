ad_page_contract {
    This page allows admins to see all the roles in a simulation case and the user
    playing each role.
} {
    case_id:integer
    {assigned_only_p 0}
}

simulation::case::get -case_id $case_id -array case

set title "Administer $case(label)"
set context [list [list . "SimPlay"] $title]
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set section_uri [apm_package_url_from_id $package_id]simplay/

set elements {
        role {
            label "Role"
            display_template {
                @roles.role@ <font size="-1">\[\<a href="@roles.add_url@">add user</a>]</font>
            }
       }    
        user_name {
            label "User"
            display_template {
                @roles.user_name@ &nbsp; <font size="-1">\[<a href="@roles.move_url@">move</a>|<a href="@roles.remove_url@">remove</a>\]</font>
            }
        }
        max_n_users {
            label "Target # users"
        }
    }

if { $assigned_only_p } {
    lappend elements assigned_action {
            label "Assigned action"
        }
}

if { $assigned_only_p } {
    set assigned_filter "<a href=\"[export_vars -base case-admin { case_id {assigned_only_p 0} }]\">Show all roles</a>"
} else {
    set assigned_filter "<a href=\"[export_vars -base case-admin { case_id {assigned_only_p 1} }]\">Show only roles with assigned actions</a>"
}

template::list::create \
    -name roles \
    -multirow roles \
    -no_data "There are no roles or users in this simulation case" \
    -elements $elements

# Set clauses for the assigned only filter
set select_clause ""
set from_clause ""
set where_clause ""
if { $assigned_only_p } {
    set select_clause ",
           wa.pretty_name as assigned_action"
    set from_clause ",
         workflow_case_enabled_actions wcea,
         workflow_actions wa"
    set where_clause "      and wcea.case_id = :case_id
      and wcea.action_id = wa.action_id
      and wa.assigned_role = wr.role_id"
}

db_multirow -extend {add_url move_url remove_url} roles select_case_info "
    select wr.role_id,
           wr.pretty_name as role,
           cu.user_id,
           cu.first_names || ' ' || cu.last_name as user_name,
           sr.users_per_case as max_n_users
           $select_clause
    from workflow_roles wr,
         workflow_cases wc,
         workflow_case_role_party_map wcrpm,
         cc_users cu,
         sim_roles sr
         $from_clause
    where wr.workflow_id = wc.workflow_id
      and wc.case_id = :case_id
      and wcrpm.case_id = wc.case_id
      and wcrpm.role_id = wr.role_id
      and cu.user_id = wcrpm.party_id
      and sr.role_id = wr.role_id
      $where_clause
" {
    set add_url [export_vars -base case-admin-user-add { case_id role_id }]
    set move_url [export_vars -base case-admin-user-move { case_id user_id }]
    set remove_url [export_vars -base case-admin-user-remove { case_id role_id user_id }]
}
