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

set elements {
    from {
        label "From"
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
    sim_name {
        label "Simulation"
        hide_p {[ad_decode [exists_and_not_null case_id] 1 1 0]}
    }
    case_label {
        label "Case"
        hide_p {[ad_decode [exists_and_not_null case_id] 1 1 0]}
    }
}

template::list::create \
    -name messages \
    -multirow messages \
    -no_data "You don't have any messages." \
    -elements $elements 

# TODO: make case_name be a combo of simulation name and case #
db_multirow -extend { message_url creation_date_pretty } messages select_messages "
    select distinct sm.message_id,
           sm.title as subject,
           sc.label as case_label,
           w.pretty_name as sim_name,
           to_char(creation_date, 'YYYY-MM-DD HH24:MI:SS') as creation_date_ansi,
           (select p.first_names || ' ' || p.last_name
              from persons p
             where p.person_id = creation_user) as from,
           (select count(*) 
              from cr_item_rels
             where item_id = item_id
               and relation_tag = 'attachment') as  attachment_count
      from sim_messagesx sm,
           workflow_case_role_party_map wcrmp,
           party_approved_member_map pamm,
           workflows w,
           workflow_cases wc,
           sim_cases sc
     where pamm.member_id = :user_id
       and wcrmp.party_id = pamm.party_id
       and wcrmp.case_id = sm.case_id
       and wc.case_id = sm.case_id
       and sc.sim_case_id = wc.object_id
       and w.workflow_id = wc.workflow_id
     [ad_decode [exists_and_not_null case_id] 1 "and sm.case_id = :case_id" ""]
" {
    set message_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/message" { message_id case_id }]
    set creation_date_pretty [lc_time_fmt $creation_date_ansi "%x %X"]
}
