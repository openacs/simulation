ad_page_contract {
    Page allows users to cast themselves in simulations with casting type open
    or group.  For casting type group the user can only choose the case to be
    in. If casting type is open he/she can also choose role.

    @author Peter Marklund
} {
    workflow_id:integer
}

auth::require_login
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
simulation::template::get -workflow_id $workflow_id -array simulation

# Check user is enrolled
set enrolled_p [simulation::template::user_enrolled_p -workflow_id $workflow_id]
if { !$enrolled_p } {
    set enroll_now_text ""
    if { [string equal $simulation(enroll_type) "open"] } {
        set link_target [export_vars -base enroll { workflow_id }]
        set enroll_now_text [_ simulation.lt_a_hreflink_targetClic]
    }

        ad_return_forbidden \
                [_ simulation.lt_Not_enrolled_in_simul] \
                [_ simulation.lt_blockquoteWe_are_sorr_5]
        ad_script_abort
}

# Check self casting is allowed
if { [string equal $simulation(casting_type) "auto"] } {
        ad_return_forbidden \
                [_ simulation.lt_You_will_be_automatic] \
                [_ simulation.lt_blockquoteThe_simulat]
        ad_script_abort    
}

template::list::create \
    -name cast_info \
    -multirow cast_info \
    -no_data [_ simulation.lt_You_are_not_cast_in_a] \
    -elements {
        case_name {
            label {[_ simulation.Case]}
        }
        role_name {
            label {[_ simulation.Role]}
        }
    }

db_multirow cast_info cast_info {
    select sc.label as case_name,
           wr.pretty_name as role_name
    from workflow_case_role_party_map wcrpm,
         workflow_cases wc,
         sim_cases sc,
         workflow_roles wr
    where wcrpm.party_id = :user_id
      and wcrpm.case_id = wc.case_id
      and wc.workflow_id = :workflow_id
      and wc.object_id = sc.sim_case_id
      and wr.role_id = wcrpm.role_id
}

set already_cast_p [expr ${cast_info:rowcount} > 0]

if { !$already_cast_p } {
    set page_title [_ simulation.lt_Join_a_Case_in_Simula_1]
} else {
    set page_title [_ simulation.lt_User_castings_in_simu]
}
set context [list [list "." [_ simulation.SimPlay]] $page_title]


template::list::create \
    -name roles \
    -multirow roles \
    -no_data [_ simulation.lt_There_are_no_cases_in] \
    -elements {
        case_pretty {
            label {[_ simulation.Case]}
        }
        case_action {
            display_template {
                <if @roles.can_join_case_p@ and @roles.join_case_url@ ne "">
                  <a href="@roles.join_case_url@" class="button">[_ simulation.join_case]</a>
                </if>
            }
        }
        role_name {
            label {[_ simulation.Role]}
        }
        role_action {
            display_template {
                <if @roles.can_join_role_p@ and @roles.join_role_url@ ne "">
                  <a href="@roles.join_role_url@" class="button">[_ simulation.join_role]</a>
                </if>
            }
        }
        n_users {
            label {[_ simulation._Users]}
            display_template {
                <if @roles.n_users@ gt 0>
                  <a href="@roles.users_url@">@roles.n_users@</a>
                </if>
                <else>
                  @roles.n_users@
                </else>
            }
        }
        max_n_users {
            label {[_ simulation.Max__users]}
        }
    }

db_multirow -extend { can_join_role_p join_case_url join_role_url users_url } roles select_case_info {
    select wc.case_id,
           wr.role_id,
          sc.label||'/'||wr.pretty_name as case_role,
           sc.label as case_pretty,
           wr.pretty_name as role_name,
           sr.users_per_case as max_n_users,
           (select count(*)
            from workflow_case_role_party_map wcrpm2
            where wcrpm2.case_id = wc.case_id
            and wcrpm2.role_id = wr.role_id
           ) as n_users,
           (select count(*)
            from sim_role_party_map srpm,
                 party_approved_member_map pamm
            where srpm.party_id = pamm.party_id
              and pamm.member_id = :user_id
              and srpm.role_id = wr.role_id
           ) as is_mapped_p    
    from workflow_cases wc,
         sim_cases sc,
         workflow_roles wr,
         sim_roles sr
    where wc.object_id = sc.sim_case_id
      and wc.workflow_id = :workflow_id
      and wr.role_id = sr.role_id
      and wr.workflow_id = :workflow_id
      order by sc.label, wr.pretty_name
} {
    # User can join a case if there is at least one role in the case that the
    # user can join

    # User can join a role if he is in a group mapped to the role and there are
    # empty spots for the role    

    if { $is_mapped_p && [expr $max_n_users - $n_users] > 0 } {
        set can_join_role_p 1
        set can_join_case_p_array($case_id) 1
    } else {
        set can_join_role_p 0
        if { ![info exists can_join_case_p_array($case_id)] } {
            set can_join_case_p_array($case_id) 0
        }
    }

    set join_case_url ""
    set join_role_url ""

    if { !$already_cast_p } {
        if { [string equal $simulation(casting_type) "group"] } {
            # Group casting - cast to case
            set join_case_url [export_vars -base cast-join { case_id }]
        } else {
            # Open casting - cast to role
            set join_role_url [export_vars -base cast-join { case_id role_id }]
        }
    }

    set users_url [export_vars -base cast-users-list { case_id role_id }]
}

template::multirow extend roles can_join_case_p
template::multirow foreach roles {
    if { $can_join_case_p_array($case_id)} {
        set can_join_case_p 1
    }
}

if { !$already_cast_p } {
    set join_new_case_url [export_vars -base cast-join { workflow_id }]
}
