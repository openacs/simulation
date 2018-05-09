ad_page_contract {
    Do enrollment and invitations for a simulation.
} {
    workflow_id:integer
}

permission::require_write_permission -object_id $workflow_id

simulation::template::get -workflow_id $workflow_id -array sim_template

switch $sim_template(enroll_type) {
    "closed" {
        set neither_label "Not participating"
    }
    "open" {
        set neither_label "Can self-enroll"
    }
    default {
        set neither_label "Self enroll/not participating"
    }
}

set group_admin_url [export_vars -base "[subsite::get_element -element url]admin/group-types/one" { { group_type group } }]

set permission_group_name [simulation::permission_group_name]

set subsite_group_id [application_group::group_id_from_package_id \
                          -package_id [site_node::closest_ancestor_package \
                                                     -node_id [ad_conn node_id] \
                                                     -package_key "acs-subsite" \
                                                     -include_self \
                                                     -element "package_id"]]

ad_form -name simulation -form {
    {workflow_id:integer(hidden) {value $workflow_id}}
}

set groups [list]

db_multirow -extend { group_radio } participants select_participants {
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
            and    type = 'invited') as invited_p,
           (select multiple_cases_p
            from sim_party_sim_map
            where simulation_id = :workflow_id
              and party_id = g.group_id) as multiple_cases_p
    from   acs_rels ar,
           groups   g
    where  ar.object_id_one = :subsite_group_id
    and    ar.object_id_two = g.group_id
    and    g.group_name <> :permission_group_name
    order  by lower(g.group_name)
} {
    ad_form -extend -name simulation -form \
        [list [list __group_$group_id:text,optional] [list __multiple_$group_id:text,optional]]

    lappend groups $group_id
    
    if { $invited_p > 0 } {
        set group_radio invited
    } elseif { $auto_enroll_p > 0 } {
        set group_radio auto_enroll
    } else { 
        set group_radio neither
    }
}

template::list::create \
    -name "participants" \
    -key group_id \
    -no_data "There are no user groups set up" \
    -elements {
        group_name {
            label "Group Name"
        }
        n_users {
            label "\# Users"
            display_eval {[lc_numeric $n_users]}
            html { align center }
        }
        invited_p {
            label "Invited"
            display_template { 
                  <input name="__group_@participants.group_id@" value="invited" type="radio" <if @participants.group_radio@ eq "invited">checked="checked"</if>>
            }
            html { align center }
        }
        auto_enroll_p {
            label "Mandatory"
            display_template {                
                  <input name="__group_@participants.group_id@" value="auto_enroll" type="radio" <if @participants.group_radio@ eq "auto_enroll">checked</if>>
            }
            html { align center }
        }
        neither {
            label $neither_label
            display_template {                
                  <input name="__group_@participants.group_id@" value="neither" type="radio" <if @participants.group_radio@ eq "neither">checked="checked"</if>>
            }
            html { align center }
        }
        multiple {
            label "Multiple Cases"
            display_template {
                <input name="__multiple_@participants.group_id@" value="t" type="checkbox"<if @participants.multiple_cases_p@ eq "t">checked="checked"</if>>
            }
            html { align center }
        }
    }

wizard submit simulation -buttons { back next }

ad_form \
    -extend \
    -name simulation \
    -form { 
        {groups:text(hidden),optional {value $groups}}
    } -on_submit {
    
        db_transaction {
            foreach group_id $groups {
                foreach type { invited auto_enroll } {
                    db_dml delete_party {
                        delete from sim_party_sim_map
                        where  simulation_id = :workflow_id
                        and    type = :type
                        and    party_id = :group_id
                    }

                    set selected_type [element get_value simulation __group_${group_id}]
                    if { [string equal $selected_type $type] } {
                        set multiple_cases_p [ad_decode [element get_value simulation __multiple_${group_id}] "t" "t" "f"]
                        db_dml insert_party {
                            insert into sim_party_sim_map (simulation_id, party_id, type, multiple_cases_p)
                            values (:workflow_id, :group_id, :type, :multiple_cases_p)
                        }
                    }
                }
            }
        }

    } -after_submit {
        simulation::template::flush_inst_state -workflow_id $workflow_id
        wizard forward
    }
