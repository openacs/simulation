simulation::include_contract {
    Displays a list of available simulations

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    party_id {
        default_value ""
    }
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

set elements {
    pretty_name {
        label "Simulation"
        orderby upper(w.pretty_name)
    }
    description {
        label "Description"
        display_template {
            @avail_sims.description;noquote@
        }
    }
    enroll {
        label "Join"
        display_template {
            <a href="@avail_sims.enroll_url@">Join</a> 
        }
    }
    
}

template::list::create \
    -name avail_sims \
    -multirow avail_sims \
    -no_data "No simulations available to join." \
    -elements $elements 

db_multirow -extend { enroll_url } avail_sims select_avail_sims "
select w.workflow_id,
       w.pretty_name,
       w.description,
       w.description_mime_type
from sim_simulations ss,
     workflows w
where ss.simulation_id = w.workflow_id
  and ss.sim_type = 'casting_sim'
  and (ss.enroll_start <= now() 
       and ss.enroll_end >= now()
       and ss.enroll_type = 'open' 
       or 
       exists (select 1
               from sim_party_sim_map spsm1,
                    party_approved_member_map pamm
               where spsm1.simulation_id = ss.simulation_id
                 and spsm1.party_id = pamm.party_id
                 and pamm.member_id = :user_id
                 and spsm1.type = 'invited'
               )
      )
  and not exists (select 1
                  from sim_party_sim_map spsm2
                  where spsm2.simulation_id = ss.simulation_id
                    and spsm2.party_id = :user_id
                    and spsm2.type = 'enrolled'
                 )
" {
    set enroll_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/enroll" {workflow_id} ]
    set description [ad_html_text_convert -from $description_mime_type -maxlen 200 -- $description]
}
