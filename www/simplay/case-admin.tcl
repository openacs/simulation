ad_page_contract {
    This page allows admins to see all the roles in a simulation case and the user
    playing each role.
} {
    case_id:integer
    {assigned_only_p 0}
}

set package_id [ad_conn package_id]
permission::require_permission -object_id $package_id -privilege sim_adminplayer

simulation::case::get -case_id $case_id -array case

set title "Administer $case(label)"
set context [list [list . "SimPlay"] $title]
set user_id [ad_conn user_id]
set section_uri [apm_package_url_from_id $package_id]simplay/

set elements {
    role {
        label "Role"
        link_url_eval {[export_vars -base case { case_id role_id }]}
    }    
    role_action {
        display_template {
            <a href="@roles.add_url@" class="button">Add user to role</a>
        }
    }
    user_name {
        label "User"
    }
    user_actions {
        label ""
        display_template {
            <a href="@roles.move_url@" class="button">Move user</a> <a href="@roles.remove_url@" class="button">Remove user</a>
        }
    }
    max_n_users {
        label "Target # users"
    }
    assigned_action {
        label "Assigned action"
        hide_p {[expr !$assigned_only_p]}
    }
}

template::list::create \
    -name roles \
    -multirow roles \
    -no_data "There are no roles or users in this simulation case" \
    -elements $elements \
    -pass_properties { case_id } \
    -filters {
        assigned_only_p {
            label "Display"
            values {
                {"All" 0}
                {"Roles with actions only" 1}
            }
            default_value 0
        }
        case_id {
            hide_p 1
        }
    }

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

set cast_roles [list]
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
   order by wr.sort_order, lower(cu.first_names), lower(cu.last_name)
" {
    set add_url [export_vars -base case-admin-user-add { case_id role_id }]
    set move_url [export_vars -base case-admin-user-move { case_id user_id }]
    set remove_url [export_vars -base case-admin-user-remove { case_id role_id user_id }]

    lappend cast_roles $role_id
}

set role_options [workflow::role::get_options -id_values -workflow_id $case(workflow_id)]
set uncast_role_options [list]
foreach role_option $role_options {
    if { [lsearch -exact $cast_roles [lindex $role_option 1]] == -1 } {
        lappend uncast_role_options $role_option
    }
}

ad_form -name add_user \
    -action case-admin-user-add \
    -export { case_id } \
    -form {
        {role_id:integer(select)
            {label "Role"}
            {options {$uncast_role_options}}
        }        
    }


set case_delete_url [export_vars -base case-delete { case_id { return_url [ad_return_url] } }]

