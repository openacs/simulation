ad_page_contract {
    Do enrollment and invitations for a simulation.
} {
    workflow_id:integer
}

permission::require_write_permission -object_id $workflow_id

simulation::template::get -workflow_id $workflow_id -array sim_template

set group_admin_url [export_vars -base "[subsite::get_element -element url]admin/group-types/one" { { group_type group } }]

set permission_group_name [simulation::permission_group_name]

set subsite_group_id [application_group::group_id_from_package_id \
                          -package_id [ad_conn subsite_id]]

ad_form -name simulation -form {
    {workflow_id:integer(hidden) {value $workflow_id}}
}

set groups [list]

db_multirow participants select_participants {
    select g.group_name,
           g.group_id,
           (select count(distinct u.user_id)
                   from party_approved_member_map pamm,
                        users u
                   where pamm.party_id = g.group_id
                     and pamm.member_id = u.user_id
           ) as n_users,
           (select count(*)
            from   sim_party_sim_map 
            where  simulation_id = :workflow_id 
            and    party_id = g.group_id 
            and    type = 'auto_enroll') as auto_enroll_p,
           (select count(*)
            from   sim_party_sim_map 
            where  simulation_id = :workflow_id 
            and    party_id = g.group_id 
            and    type = 'invited') as invited_p
    from   acs_rels ar,
           groups   g
    where  ar.object_id_one = :subsite_group_id
    and    ar.object_id_two = g.group_id
    and    g.group_name <> :permission_group_name
    order  by lower(g.group_name)
} {
    ad_form -extend -name simulation -form \
        [list [list __auto_enroll_$group_id:text,optional]]

    ad_form -extend -name simulation -form \
        [list [list __invited_$group_id:text,optional]]

    lappend groups $group_id
}

template::list::create \
    -name "participants" \
    -key group_id \
    -elements {
        group_name {
            label "Group Name"
        }
        n_users {
            label "\# Users"
            display_eval {[lc_numeric $n_users]}
            html { align right }
        }
        invited_p {
            label "Invited"
            display_template { 
                <if @participants.invited_p@ true>
                  <input name="__invited_@participants.group_id@" value="t" type="checkbox" checked>
                </if>
                <else>
                  <input name="__invited_@participants.group_id@" value="t" type="checkbox">
                </else>
            }
            html { align center }
        }
        auto_enroll_p {
            label "Mandatory Participation"
            display_template {
                <if @participants.auto_enroll_p@ true>
                  <input name="__auto_enroll_@participants.group_id@" value="t" type="checkbox" checked>
                </if>
                <else>
                  <input name="__auto_enroll_@participants.group_id@" value="t" type="checkbox">
                </else>
            }
            html { align center }
        }
    }
#                <formwidget id="auto_enroll_@participants.group_id@">

wizard submit simulation -buttons { back next }

ad_form \
    -extend \
    -name simulation \
    -form { 
        {groups:text(hidden),optional {value $groups}}
    } \
    -on_request {
        # Grab values from local vars 
    } \
    -on_submit {
    
        # First, drop all "invited" check marks if the user is also auto-enrolled
        foreach group_id $groups {
            if { [exists_and_equal __invited_${group_id} "t"] && [exists_and_equal __auto_enroll_${group_id} "t"] } {
                unset __invited_${group_id}
            }
        }

        db_transaction {
            foreach group_id $groups {
                foreach type { invited auto_enroll } {
                    db_dml delete_party {
                        delete from sim_party_sim_map
                        where  simulation_id = :workflow_id
                        and    type = :type
                        and    party_id = :group_id
                    }
                    if { [exists_and_equal __${type}_${group_id} "t"] } {
                        db_dml insert_party {
                            insert into sim_party_sim_map (simulation_id, party_id, type)
                            values (:workflow_id, :group_id, :type)
                        }
                    }
                }
            }
        }

    } -after_submit {
        wizard forward
    }

