simulation::include_contract {
    Displays action, and optionally message and document, history for
    a simulation case.

    @author Peter Marklund
} {
    case_id {}
    actions_only_p {
        default_value 1
    }
    show_body_p {
        default_value 0
    }
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
            label "Task"
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
    -no_data "No documents" \
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
           ao.creation_user,
           cr.mime_type
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
