simulation::include_contract {
    Displays a list of messages for the specified role/case combo.

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    user_id {
        default_value ""
    }
}

set package_id [ad_conn package_id]

set elements {
    case_name {
        label "Case"
    }
    from {
        label "From"
    }
    subject {
        link_url_col
        message_url
        label "Subject"
    }
    date {
        label "Date"
    }
    attachment_count {
        label "Attachments"
    }
}

template::list::create \
    -name messages \
    -multirow messages \
    -no_data "You don't have any messages." \
    -elements $elements 

# TODO: make case_name be a combo of simulation name and case #
db_multirow -extend { message_url } messages select_messages "
    select distinct sm.message_id,
           sm.title as subject,
           sm.case_id as case_name,
           creation_date as date,
           (select p.first_names || ' ' || p.last_name
              from persons p
             where p.person_id = creation_user) as from,
           (select count(*) 
              from cr_item_rels
             where item_id = item_id
               and relation_tag = 'attachment') as  attachment_count
      from sim_messagesx sm,
           workflow_case_role_party_map wcrmp,
           party_approved_member_map pamm
     where pamm.member_id = :user_id
       and wcrmp.party_id = pamm.party_id
       and wcrmp.case_id = sm.case_id
" {
    set message_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/message" { message_id }]
}
