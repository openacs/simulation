simulation::include_contract {
    Displays a list of messages for the specified role/case combo.

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    user_id {
        default_value {}
    }
    case_id {
        default_value {}
    }
    role_id {
        default_value {}
    }
    limit {
        default_value {}
    }
}

set package_id [ad_conn package_id]
set adminplayer_p [permission::permission_p -object_id $package_id -privilege sim_adminplayer]

if { ![exists_and_not_null case_id] || ![exists_and_not_null role_id] } {
    if { !$adminplayer_p } {
        error "You must supply both case_id and role_id"
    } else {
        set mode "admin"
    }
} else {
    set mode "user"
}

set elements {
    from {
        label "From"
    }
    to {
        label "To"
    }
    subject {
        link_url_col message_url
        label "Subject"
    }
    creation_date {
        label "Received"
        display_col creation_date_pretty
    }
    attachment_count {
        label "Attachments"
        html { align center }
    }
    case_label {
        label "Case"
        hide_p {[ad_decode [exists_and_not_null case_id] 1 1 0]}
    }
    sim_name {
        label "Simulation"
        hide_p {[ad_decode [exists_and_not_null case_id] 1 1 0]}
    }
}

if { [exists_and_not_null case_id] && [exists_and_not_null role_id] } {
    set actions [list "Send new message" [export_vars -base message { case_id role_id }] {}]
} else {
    set actions [list]
}

template::list::create \
    -name messages \
    -multirow messages \
    -no_data "No messages." \
    -actions $actions \
    -elements $elements

db_multirow -extend { message_url creation_date_pretty } messages select_messages "
    select sm.message_id,
           cr.item_id,
           sm.title as subject,
           sc.label as case_label,
           w.pretty_name as sim_name,
           sm.creation_date,
           to_char(sm.creation_date, 'YYYY-MM-DD HH24:MI:SS') as creation_date_ansi,
           (select fr.pretty_name
              from workflow_roles fr
             where fr.role_id = sm.from_role_id) as from,
           (select tr.pretty_name
              from workflow_roles tr
             where tr.role_id = sm.to_role_id) as to,
           (select count(*) 
              from cr_item_rels
             where item_id = sm.item_id
               and relation_tag = 'attachment') as  attachment_count,
           sm.to_role_id,
           sm.case_id as msg_case_id
    from   sim_messagesx sm,
           cr_revisions cr,
           workflows w,
           workflow_cases wc,
           sim_cases sc
    where  cr.revision_id = sm.message_id
    and    wc.case_id = sm.case_id
    [ad_decode $role_id "" "" "and    (sm.to_role_id = :role_id or sm.from_role_id = :role_id)"]
    and    wc.case_id = sm.case_id
    and    sc.sim_case_id = wc.object_id
    and    w.workflow_id = wc.workflow_id
    [ad_decode $case_id "" "" "and wc.case_id = :case_id"]
    [ad_decode $user_id "" "" "and exists (select 1 from workflow_case_role_user_map where case_id = wc.case_id and (sm.to_role_id = role_id or sm.from_role_id = role_id) and user_id = :user_id)"]
    order  by sm.creation_date desc
    [ad_decode $limit "" "" "limit $limit"]
" {
    if { ![empty_string_p $role_id] } {
        set message_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/message" { item_id case_id role_id }]
    } else {
        set message_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/message" { item_id { case_id $msg_case_id } { role_id $to_role_id } }]
    }
    set creation_date_pretty [lc_time_fmt $creation_date_ansi "%x %X"]
}
