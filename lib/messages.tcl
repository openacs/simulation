simulation::include_contract {
    Displays a list of messages for the specified role/case combo.

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    user_id {
        default_value ""
    }
    case_id {
        required_p 0
    }
}

set package_id [ad_conn package_id]

if { [exists_and_not_null case_id] } {
    set user_roles [workflow::case::get_user_roles -case_id $case_id]
} else {
    set user_roles [list]
}

set elements {
    from {
        label "From"
    }
    to {
        label "To"
        hide_p {[ad_decode [llength $user_roles] 1 1 0]}
    }
    subject {
        link_url_col
        message_url
        label "Subject"
    }
    creation_date_pretty {
        label "Received"
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

template::list::create \
    -name messages \
    -multirow messages \
    -no_data "You don't have any messages." \
    -actions [list "Send new message" [export_vars -base message { case_id }] {}] \
    -elements $elements 

db_multirow -extend { message_url creation_date_pretty } messages select_messages "
    select distinct sm.message_id,
           cr.item_id,
           sm.title as subject,
           sc.label as case_label,
           w.pretty_name as sim_name,
           to_char(creation_date, 'YYYY-MM-DD HH24:MI:SS') as creation_date_ansi,
           (select fr.pretty_name
              from workflow_roles fr
             where fr.role_id = sm.from_role_id) as from,
           (select tr.pretty_name
              from workflow_roles tr
             where tr.role_id = sm.to_role_id) as to,
           (select count(*) 
              from cr_item_rels
             where item_id = item_id
               and relation_tag = 'attachment') as  attachment_count
    from   sim_messagesx sm,
           cr_revisions cr,
           workflow_case_role_party_map wcrmp,
           party_approved_member_map pamm,
           workflows w,
           workflow_cases wc,
           sim_cases sc
    where  cr.revision_id = sm.message_id
    and    pamm.member_id = :user_id
    and    wcrmp.party_id = pamm.party_id
    and    wcrmp.case_id = sm.case_id
    and    wcrmp.role_id = sm.to_role_id
    and    wc.case_id = sm.case_id
    and    sc.sim_case_id = wc.object_id
    and    w.workflow_id = wc.workflow_id
    [ad_decode [exists_and_not_null case_id] 1 "and sm.case_id = :case_id" ""]
" {
    set message_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/message" { item_id case_id }]
    set creation_date_pretty [lc_time_fmt $creation_date_ansi "%x %X"]
}
