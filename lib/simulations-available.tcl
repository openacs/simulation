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

    # TODO: if invited instead of open, say "accept invitation to enroll"

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
        label "Enroll"
        display_template {
            <a href="@avail_sims.enroll_url@">Self-enroll</a> 
        }
    }
    
}

template::list::create \
    -name avail_sims \
    -multirow avail_sims \
    -no_data "No simulations available to self-enroll." \
    -elements $elements 

# TODO: verify that the first half of this query returns the sims to which the user is invited (data model may have changed since this was coded)
# TODO: exclude simulations for which the user is currently enrolled

db_multirow -extend {enroll_url} avail_sims select_avail_sims "
    select w.workflow_id,
           w.pretty_name,
           w.description,
           w.description_mime_type
      from workflows w,
           sim_party_sim_map spsm
     where w.workflow_id = spsm.simulation_id
       and spsm.simulation_id = :party_id
    UNION
    select w.workflow_id,
           w.pretty_name,
           w.description,
           w.description_mime_type
      from workflows w,
           sim_simulations ss
     where ss.simulation_id = w.workflow_id
       and ss.enroll_start <= now() 
       and ss.enroll_end >= now()
       and ss.enroll_type = 'open'
" {
    set enroll_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/enroll" {workflow_id} ]
    set description [ad_html_text_convert -from $description_mime_type -maxlen 200 -- $description]

}