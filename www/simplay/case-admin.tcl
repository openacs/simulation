ad_page_contract {
    This page allows admins to see all the roles in a simulation case and the user
    playing each role.
} {
    case_id:integer
    {assigned_only_p 0}
    {actions_only_p 1}
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
        link_url_col user_url
    }
    user_actions {
        label ""
        display_template {
            <a href="@roles.move_url@" class="button">Move user</a> <a href="@roles.remove_url@" class="button">Remove user</a>
        }
    }
    max_n_users {
        label "Target # users"
        html { align center }
    }
    assigned_action {
        label "Assigned action"
        hide_p {[expr !$assigned_only_p]}
    }
    portfolio {
        label "Portfolio"
        display_template {
            @roles.num_documents@ documents
        }
        link_url_eval {[export_vars -base case-admin-portfolio { case_id role_id }]}
        html { align center }
    }
    messages {
        label "Messages"
        display_template {
            @roles.num_messages@ messages
        }
        link_url_eval {[export_vars -base case-admin-messages { case_id role_id }]}
        html { align center }
    }
}

template::list::create \
    -name roles \
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
db_multirow -extend { add_url move_url remove_url user_url } roles select_case_info "
    select wr.role_id,
           wr.pretty_name as role,
           cu.user_id,
           cu.first_names || ' ' || cu.last_name as user_name,
           (select count(*) 
            from   sim_messages
            where  (to_role_id = wr.role_id or from_role_id = wr.role_id)
              and case_id = :case_id) as num_messages,
           (select count(*) 
            from   sim_case_role_object_map
            where  role_id = wr.role_id
              and  case_id = :case_id) as num_documents,
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
    set user_url [acs_community_member_url -user_id $user_id]
    
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


#----------------------------------------------------------------------
# Case activity history
#----------------------------------------------------------------------

if { $actions_only_p } {
    set toggle_url [export_vars -base case-admin { case_id assigned_only_p {actions_only_p 0}}]
    set case_history_filter "Display \[ <b>Only actions</b> | <a href=\"$toggle_url\">Actions, messages, and documents</a> \]"
} else {
    set toggle_url [export_vars -base case-admin { case_id assigned_only_p {actions_only_p 1}}]
    set case_history_filter "Display \[ <a href=\"$toggle_url\">Only actions</a> | <b>Actions, messages, and documents</b> \]"
}

template::list::create \
    -name log \
    -elements {
        timestamp {
            label "Time"
            display_eval {[lc_time_fmt $creation_date_ansi "%x %X"]}
        }
        role_pretty {
            label "Role"
        }
        user_name {
            label "User"
            link_url_eval {[acs_community_member_url -user_id $creation_user]}
        }
        action_pretty {
            label "Action"
            link_url_col action_url
        }
    }

db_multirow -extend { action_url } log select_log {
    select l.entry_id,
           l.case_id,
           l.action_id,
           a.short_name as action_short_name,
           a.pretty_name as action_pretty,
           a.pretty_past_tense as action_pretty_past_tense,
           role.role_id,
           role.pretty_name as role_pretty,
           io.creation_user,
           iou.first_names || ' ' || iou.last_name as user_name,
           to_char(io.creation_date, 'YYYY-HH-MM HH24:MI:SS') as creation_date_ansi,
           (select min(item_id)
            from   sim_messagesx
            where  entry_id = l.entry_id) as message_item_id,
           (select min(name) 
            from   sim_case_role_object_map,
                   cr_items
            where  entry_id = l.entry_id
            and    item_id = object_id) as document_name
    from   workflow_case_log l join 
           workflow_actions a using (action_id) join 
           cr_items i on (i.item_id = l.entry_id) join 
           acs_objects io on (io.object_id = i.item_id) join 
           cc_users iou on (iou.user_id = io.creation_user) join
           cr_revisions r on (r.revision_id = i.live_revision),
           workflow_roles role
    where  l.case_id = :case_id
    and    role.role_id = a.assigned_role
    and    a.trigger_type = 'user'
    order  by io.creation_date
} {
    if { ![empty_string_p $message_item_id] } {
        set action_url [export_vars -base message { case_id role_id { item_id $message_item_id } }]
    } elseif { ![empty_string_p $document_name] } {
        set action_url [simulation::object::content_url -name $document_name]
    } else {
        set action_url {}
    }
}

template::list::create \
    -name documents \
    -no_data "No documents uploaded in this simulation case" \
    -elements {
        timestamp {
            label "Time"
            display_eval {[lc_time_fmt $creation_date_ansi "%x %X"]}
        }
        role_pretty {
            label "Role"
        }
        user_name {
            label "User"
            link_url_eval {[acs_community_member_url -user_id $creation_user]}
        }
        document_pretty {
            label "Document"
            link_url_col document_url
        }        
    }

db_multirow -extend { document_url } documents select_documents {
    select to_char(ao.creation_date, 'YYYY-HH-MM HH24:MI:SS') as creation_date_ansi,
           wr.pretty_name as role_pretty,
           cu.first_names || ' ' || cu.last_name as user_name,
           cr.title as document_pretty,
           ci.name as document_name,
           ao.creation_user
    from sim_case_role_object_map scrom,
         workflow_roles wr,
         acs_objects ao,
         cc_users cu,
         cr_items ci,
         cr_revisions cr
    where scrom.role_id = wr.role_id
      and scrom.object_id = ao.object_id
      and scrom.case_id = :case_id
      and cu.user_id = ao.creation_user
      and ci.item_id = ao.object_id
      and ci.live_revision = cr.revision_id
    order  by ao.creation_date
} {
    set document_url [simulation::object::content_url -name $document_name]
}
