simulation::include_contract {
    Displays a list of messages for the specified role/case combo.

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    party_id {
        default_value ""
    }
}

set package_id [ad_conn package_id]

set elements {
    subject {
        label "Subject"
    }
    date {
        label "Date"
    }
    from {
        label "From"
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

db_multirow messages select_messages "
    select title as subject,
           creation_date as date,
           (select p.first_names || ' ' || p.last_name
              from persons p
             where p.person_id = creation_user) as from,
           (select count(*) 
              from cr_item_rels
             where item_id = item_id
               and relation_tag = 'attachment') as  attachment_count
      from sim_messagesi
"