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
    show_body_p {
        default_value 0
    }
}

set package_id [ad_conn package_id]
set adminplayer_p [permission::permission_p -object_id $package_id -privilege sim_adminplayer]

if { ![exists_and_not_null case_id] || ![exists_and_not_null role_id] } {
    if { !$adminplayer_p } {
        error [_ simulation.lt_You_must_supply_both]
    } else {
        set mode "admin"
    }
} else {
    set mode "user"
}

set elements {
    from {
        label {[_ simulation.From]}
    }
    to {
        label {[_ simulation.To]}
    }
    subject {
        link_url_col message_url
        label {[_ simulation.Subject]}
    }
    creation_date {
        label {[_ simulation.Received]}
        display_col creation_date_pretty
    }
    attachment_count {
        label {[_ simulation.Attachments]}
        html { align center }
    }
    case_label {
        label {[_ simulation.Case]}
        hide_p {[ad_decode [exists_and_not_null case_id] 1 1 0]}
    }
    sim_name {
        label {[_ simulation.Simulation]}
        hide_p {[ad_decode [exists_and_not_null case_id] 1 1 0]}
    }
}

set extend { message_url creation_date_pretty }

if { $show_body_p } {
    lappend elements body
    lappend elements {
        label {[_ simulation.Body]}
    }

    lappend extend body
}

if { [exists_and_not_null case_id] } {
    set num_enabled_actions [db_string select_num_enabled_actions { 
        select count(*) 
        from   workflow_case_enabled_actions 
        where  case_id = :case_id
    }]
    set complete_p [expr $num_enabled_actions == 0]
} else {
    set complete_p 0
}

if { [string match $complete_p "0"] && [exists_and_not_null role_id] } {
    set actions [list [_ simulation.Send_new_message] [export_vars -base message { case_id role_id }] {}]
} else {
    set actions [list]
}

template::list::create \
    -name messages \
    -multirow messages \
    -no_data [_ simulation.No_messages] \
    -actions $actions \
    -elements $elements

db_multirow -extend $extend messages select_messages "
    select sm.message_id,
           cr.item_id,
           sm.title as subject,
           sc.label as case_label,
           w.pretty_name as sim_name,
           sm.creation_date,
           to_char(sm.creation_date, 'YYYY-MM-DD HH24:MI:SS') as creation_date_ansi,
           (select wr.pretty_name || ' (' || scx.title || ')' as from
              from sim_roles fr, 
                   sim_charactersx scx,
                   cr_items ci,
                   workflow_roles wr
             where fr.role_id = sm.from_role_id
             and   fr.role_id = wr.role_id
             and   scx.item_id = fr.character_id
             and   ci.item_id = scx.item_id
             and   ci.live_revision = scx.object_id) as from,
           (select wr.pretty_name || ' (' || scx.title || ')' as to
              from sim_roles tr,
                   sim_charactersx scx,
                   cr_items ci,
                   workflow_roles wr
             where tr.role_id = sm.to_role_id
             and   tr.role_id = wr.role_id
             and   scx.item_id = tr.character_id
             and   ci.item_id = scx.item_id
             and   ci.live_revision = scx.object_id) as to,
           (select count(*) 
              from cr_item_rels
             where item_id = sm.item_id
               and relation_tag = 'attachment') as  attachment_count,
           sm.to_role_id,
           sm.case_id as msg_case_id
           [ad_decode $show_body_p 0 "" ", cr.content, cr.mime_type"]
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

    if { $show_body_p } {
        set body [ad_html_text_convert -from $mime_type -to "text/plain" $content]
    }
}