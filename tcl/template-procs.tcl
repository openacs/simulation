ad_library {
    API for Simulation templates.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::template {}

#----------------------------------------------------------------------
# Basic Workflow API implementation
#----------------------------------------------------------------------

ad_proc -public simulation::template::edit {
    {-operation "update"}
    {-workflow_id {}}
    {-array {}}
    {-internal:boolean}
} {
    Edit a workflow.

    @param operation    insert, update, delete

    @param workflow_id  For update/delete: The workflow to update or delete. 

    @param array        For insert/update: Name of an array in the caller's namespace with attributes to insert/update.

    @param internal     Set this flag if you're calling this proc from within the corresponding proc 
                        for a particular workflow model. Will cause this proc to not flush the cache 
                        or call workflow::definition_changed_handler, which the caller must then do.

    @return workflow_id
    
    @see workflow::edit
} {
    switch $operation {
        update - delete {
            if { [empty_string_p $workflow_id] } {
                error "You must specify the workflow_id of the workflow to $operation."
            }
        }
        insert {}
        default {
            error "Illegal operation '$operation'"
        }
    }
    switch $operation {
        insert - update {
            upvar 1 $array org_row
            if { ![array exists org_row] } {
                error "Array $array does not exist or is not an array"
            }
            array set row [array get org_row]
        }
    }
    switch $operation {
        insert {
            if { ![exists_and_not_null row(sim_type)] } {
                set row(sim_type) "dev_template"
            }
        }
    }

    # Parse column values
    switch $operation {
        insert - update {
            set update_clauses [list]
            set insert_names [list]
            set insert_values [list]

            # Handle columns in the sim_tasks table
            foreach attr { 
                sim_type suggested_duration
                enroll_type casting_type
                enroll_start enroll_end send_start_note_date case_start case_end
            } {
                if { [info exists row($attr)] } {
                    set varname attr_$attr
                    # Convert the Tcl value to something we can use in the query
                    switch $attr {
                        suggested_duration {
                            if { [empty_string_p $row($attr)] } {
                                set $varname [db_null]
                            } else {
                                # TODO B: need better tests for duration before passing it into the database.
                                set $varname "interval '[db_quote $row($attr)]'"
                            }
                        }
                        default {
                            set $varname $row($attr)
                        }
                    }
                    # Add the column to the insert/update statement
                    switch $attr {
                        enroll_start - enroll_end - send_start_note_date - case_start - case_end {
                            if { [empty_string_p $row($attr)] } {
                                lappend update_clauses "$attr = null"
                                lappend insert_names $attr
                                lappend insert_values "null"
                            } else {
                                lappend update_clauses "$attr = to_date('[db_quote $row($attr)]', 'YYYY-MM-DD')"
                                lappend insert_names $attr
                                lappend insert_values "to_date('[db_quote $row($attr)]', 'YYYY-MM-DD')"
                            }
                        }
                        suggested_duration {
                            if { [empty_string_p $row($attr)] } {
                                lappend update_clauses "$attr = :$varname"
                                lappend insert_names $attr
                                lappend insert_values :$varname
                            } else {
                                lappend update_clauses "$attr = [set $varname]"
                                lappend insert_names $attr
                                lappend insert_values [set $varname]
                            }
                        }
                        default {
                            lappend update_clauses "$attr = :$varname"
                            lappend insert_names $attr
                            lappend insert_values :$varname
                        }
                    }
                    unset row($attr)
                }
            }
            # Handle auxillary rows
            array set aux [list]
            foreach attr { 
                enrolled invited auto_enroll
            } {
                if { [info exists row($attr)] } {
                    set aux($attr) $row($attr)
                    unset row($attr)
                }
            }

        }
    }
    
    db_transaction {
        # Base row
        set workflow_id [workflow::edit \
                           -internal \
                           -operation $operation \
                           -workflow_id $workflow_id \
                           -array row]

        # sim_tasks row
        switch $operation {
            insert {
                lappend insert_names simulation_id
                lappend insert_values :workflow_id

                db_dml insert_workflow "
                    insert into sim_simulations
                    ([join $insert_names ", "])
                    values
                    ([join $insert_values ", "])
                "
            }
            update {
                if { [llength $update_clauses] > 0 } {
                    db_dml update_workflow "
                        update sim_simulations
                        set    [join $update_clauses ", "]
                        where  simulation_id = :workflow_id
                    "
                }
            }
            delete {
                # Handled through cascading delete
            }
        }
        
        # Update sim_party_sim_map table
        foreach map_type { enrolled invited auto_enroll } {
            if { [info exists aux($map_type)] } {
                # Clear out old mappings first
                db_dml clear_old_mappings {
                    delete from sim_party_sim_map
                    where simulation_id = :workflow_id
                      and type = :map_type
                }

                # Map each party
                foreach party_id $aux($map_type) {
                    db_dml map_party_to_template {
                        insert into sim_party_sim_map
                        (simulation_id, party_id, type)
                        values (:workflow_id, :party_id, :map_type)
                    }
                }
                unset aux($map_type)
            }
        }

        if { !$internal_p } {
            workflow::definition_changed_handler -workflow_id $workflow_id
        }
    }

    if { !$internal_p } {
        workflow::flush_cache -workflow_id $workflow_id
    }

    return $workflow_id
}

ad_proc -public simulation::template::get {
    {-workflow_id:required}
    {-array:required}
} {
    Return information about a simulation template.  This is a wrapper around 
    workflow::get, supplementing it with the columns from sim_simulation.

    @param workflow_id ID of simulation template.
    @param array name of array in which the info will be returned
                 Array will contain keys from the tables workflows and sim_simulations.

    @see simulation::template::get_parties
} {
    upvar $array row

    workflow::get -array row -workflow_id $workflow_id

    db_1row select_template {} -column_array local_row
    array set row [array get local_row]
}

ad_proc -public simulation::template::get_element {
    {-workflow_id:required}
    {-element:required}
} {
    Return element from a simulation template.

    @param workflow_id ID of simulation template.
    @param element The name of the element you want.

} {

    get -workflow_id $workflow_id -array row
    return $row($element)
}

ad_proc -public simulation::template::delete {
    {-workflow_id:required}
} {
    Delete a simulation template.

    @author Peter Marklund
} {
    simulation::template::edit -workflow_id $workflow_id -operation delete
}

ad_proc -public simulation::template::get_options {
    -package_id
    {-sim_type "ready_template"}
} {
    Get options-list of workflows mapped to the given object, suitable for using in a form.
} {
    if { ![exists_and_not_null package_id] } {
        set package_id [ad_conn package_id]
    }
    
    return [db_list_of_lists workflows {
        select w.pretty_name, w.workflow_id
        from   workflows w,
               sim_simulations s
        where  w.object_id = :package_id
        and    s.simulation_id = w.workflow_id
        and    s.sim_type = :sim_type
        order  by lower(w.pretty_name)
    }]
}



#----------------------------------------------------------------------
# Additional API implementations
#----------------------------------------------------------------------

ad_proc -public simulation::template::delete_role_party_mappings {
    {-workflow_id}
} {
    Clear out all role-party mappings for a template. Used when editing
    the mappings before adding the new ones.

    @author Peter Marklund
} {
        db_dml clear_old_group_mappings {
            delete from sim_role_party_map
            where role_id in (select role_id
                              from workflow_roles
                              where workflow_id = :workflow_id
                              )
        }
}

ad_proc -public simulation::template::new_role_party_mappings {
    {-role_id:required}
    {-parties:required}
} {
    Map a list of parties to a role

    @param parties A list of party ids to map to the role

} {
    foreach party_id $parties {   
        db_dml map_group_to_role {
            insert into sim_role_party_map (role_id, party_id)
            values (:role_id, :party_id)
        }
    }
}

ad_proc -public simulation::template::role_party_mappings {
    {-workflow_id}
    {-array:required}
} {
    Return a nested array list with the parties mapped to roles and
    the desired number of users to play a role per case for the given simulation
    template

    @param array The name of the array to put the information in. The array list
                 will be nested on the following format:
                 <pre>
                {
                    $role_id1 {
                        parties {$group_id1 $group_id2 ...}
                        users_per_case $users_per_case1
                    }

                    $role_id2 {
                        parties {$group_id1 $group_id2 ...}
                        users_per_case $users_per_case2
                    }
                }              
               </pre>
} {    
    upvar $array roles

    array set roles {}

    db_foreach select_party_mappings {
            select srpm.role_id,
            srpm.party_id,
            sr.users_per_case
            from sim_role_party_map srpm,
                 sim_roles sr,
                 workflow_roles wr
            where srpm.role_id = wr.role_id
              and wr.workflow_id = :workflow_id
              and srpm.role_id = sr.role_id
    } {
        array unset one_role
        array set one_role {}
        if { [info exists roles($role_id)] } {
            array set one_role $roles($role_id)
        }

        set one_role(users_per_case) $users_per_case
        lappend one_role(parties) $party_id


        set roles($role_id) [array get one_role]
    }
}
 
ad_proc -public simulation::template::get_parties {
    {-members:boolean}
    {-workflow_id:required}
    {-rel_type "auto_enroll"}
} {
    Return a list of parties related to the given simulation.

    @param rel_type The type of relationship of the party to the
                    simulation template. Permissible values are
                    enrolled, invited, and auto_enroll
    @param members  Provide this switch if you want all members of
                    the simulation parties rather than the parties
                    themselves.
    
    @return A list of party_id:s
} {
    ad_assert_arg_value_in_list rel_type { enrolled invited auto_enroll }

    if { $members_p } {
        return [db_list template_parties {
            select pamm.member_id
            from sim_party_sim_map spsm,
                 party_approved_member_map pamm
            where spsm.simulation_id = :workflow_id
             and spsm.type = :rel_type
             and pamm.party_id = spsm.party_id             
             and pamm.party_id <> pamm.member_id
        }]
    } else {
        return [db_list template_parties {
            select party_id
            from sim_party_sim_map
            where simulation_id = :workflow_id
             and type = :rel_type
        }]
    }
}

ad_proc -public simulation::template::associate_object {
    -template_id:required
    -object_id:required
} {
    Associate an object with a simulation template.  Succeeds if the record is added or already exists.
} {
      set exists_p [db_string row_exists {
          select count(*) 
            from sim_workflow_object_map
          where workflow_id =  :template_id
            and object_id = :object_id
      }]

    if { ! $exists_p } {
        db_dml add_object_to_workflow_insert {
            insert into sim_workflow_object_map
            values (:template_id, :object_id)
        }
    }
}

ad_proc -public simulation::template::dissociate_object {
    -template_id:required
    -object_id:required
} {
    Dissociate an object with a simulation template
} {
    db_dml remove_object_from_workflow_delete {
            delete from sim_workflow_object_map
            where workflow_id =  :template_id
              and object_id = :object_id
    }
    # no special error handling because the delete is pretty safe
}

ad_proc -public simulation::template::force_start {
     {-workflow_id:required}
} {
    Force a simulation to start immediately by updating case_start,
    enroll_end, and enroll_start properties to reflect an immediate start
    and then directly invoking simulation::template::start.

    @author Peter Marklund
} {
    simulation::template::get -workflow_id $workflow_id -array simulation

    db_transaction {
        # Move enroll_end to now if it's in the future
        set today [db_string select_today {
            select to_char(current_timestamp, 'YYYY-MM-DD')
        }]
        if { [clock scan $today] < [clock scan $simulation(enroll_end)] } {
            set simulation_edit(enroll_end) $today
        }
        # enroll_start must be before or equal enroll_end
        if { [clock scan $today] < [clock scan $simulation(enroll_start)] } {
            set simulation_edit(enroll_start) $today
        }

        # Set start_date to now
        set simulation_edit(case_start) $today

        simulation::template::edit -workflow_id $workflow_id -array simulation_edit

        simulation::template::start -workflow_id $workflow_id
    }
}

ad_proc -public simulation::template::enroll_and_invite_users {
     {-workflow_id:required}
} {
    Enroll users in a simulation and notify them by email if casting
    type is open or group.

    @author Peter Marklund
} {
    set simulation_edit(enrolled) [list]
    set enroll_email_list [list]
    set invite_email_list [list]
    db_foreach select_enrolled_and_invited_users {
            select distinct pamm.member_id as user_id,
                   cu.email,
                   cu.first_names || ' ' || cu.last_name as user_name,
                   spsm.type
            from sim_party_sim_map spsm,
                 party_approved_member_map pamm,
                 cc_users cu
            where spsm.simulation_id = :workflow_id
             and (spsm.type = 'auto_enroll' or spsm.type = 'invited')
             and pamm.party_id = spsm.party_id
             and pamm.member_id = cu.user_id
             and pamm.party_id <> pamm.member_id
    } {
        if { [string equal $type "auto_enroll"] } {
            # enroll the user automatically
            lappend simulation_edit(enrolled) $user_id
            lappend enroll_email_list [list $email $user_name]
        } else {
            # Invite the user
            lappend invite_email_list [list $email $user_name]            
        }
    }

    simulation::template::edit -workflow_id $workflow_id -array simulation_edit

    simulation::template::get -workflow_id $workflow_id -array sim_template

    if { [string equal $sim_template(casting_type) "open"] || [string equal $sim_template(casting_type) "group"] } {
        # Notify users that they are enrolled and can do their casting
        foreach user $enroll_email_list {
            set email [lindex $user 0]
            set user_name [lindex $user 1]

            set subject "You have been enrolled in simulation $sim_template(pretty_name)"
            # TODO: check that link to casting page is correct
            set package_id [ad_conn package_id]
            set casting_page_url \
                [export_vars -base "[ad_url][apm_package_url_from_id $package_id]/simplay/enroll" { email }]
            set body "Dear $user_name,
This is to notify you that you have been enrolled in simulation $sim_template(pretty_name). You may visit the
casting page at ${casting_page_url}.
"

            acs_mail_lite::send \
                -to_addr $email \
                -from_addr [ad_system_owner] \
                -subject $subject\
                -body $body
        }
    } 

    # Invite users
    foreach user $invite_email_list {
        set email [lindex $user 0]
        set user_name [lindex $user 1]        

        # TODO: check that link to enrollment page is correct
        set package_id [ad_conn package_id]
        set enrollment_page_url \
            [export_vars -base "[ad_url][apm_package_url_from_id $package_id]/simplay/enroll" { email }]
        set subject "You have been invited to join simulation $sim_template(pretty_name)"
        set body "Dear $user_name,
You have been invited to join simulation $sim_template(pretty_name). Please visit the enrollment page at $enrollment_page_url to accept the invitation. Thank you!"
        acs_mail_lite::send \
            -to_addr $email \
            -from_addr [ad_system_owner] \
            -subject $subject\
            -body $body
    }
}

ad_proc -private simulation::template::sweeper {} {
    Starts simulations and sends notifications.

    @author Peter Marklund
} {
    # Make simulations go live
    set simulations_to_start [db_list select_simulations_to_start {
        select simulation_id
        from sim_simulations
        where sim_type <> 'live_sim'
        and case_start < current_timestamp
    }]    
    foreach simulation_id $simulations_to_start {
        ns_log Notice "pm debug starting simulation $simulation_id"
        start -workflow_id $simulation_id
    }    

    # For simulations that are not live yet and have reached their send_start_note_date, 
    # send notifications to users in simulations that have not already been emailed.
    set users_to_notify [db_list_of_lists select_simulations_to_start {
        select cu.user_id,
               cu.email,
               cu.first_names || ' ' || cu.last_name as user_name,
               ss.simulation_id,
               w.pretty_name as simulation_name,
               to_char(ss.case_start, 'YYYY-MM-DD') as simulation_start_date,
               w.description as simulation_description
        from sim_simulations ss,
             workflows w,
             sim_party_sim_map spsm,
             cc_users cu
        where sim_type <> 'live_sim'
        and ss.simulation_id = spsm.simulation_id
        and ss.simulation_id = w.workflow_id
        and spsm.type = 'enrolled'
        and cu.user_id = spsm.party_id
        and ss.send_start_note_date < current_timestamp
        and not exists (select 1
                        from sim_simulation_emails sse
                        where sse.simulation_id = ss.simulation_id
                          and sse.user_id = spsm.party_id
                          and sse.email_type = 'reminder')        
    }]    
    foreach row $users_to_notify {
        set user_id [lindex $row 0]        
        set email [lindex $row 1]
        set user_name [lindex $row 2]
        set simulation_id [lindex $row 3]
        set simulation_name [lindex $row 4]
        set simulation_start_date [lindex $row 5]
        set simulation_description [lindex $row 6]

        set subject "Simulation $simulation_name starts on $simulation_start_date"
        set body "Dear $user_name,
this email is sent to you as a reminder that you are participating in simulation $simulation_name that will start on $simulation_start_date. Here is the
simulation description:

$simulation_description"

        acs_mail_lite::send \
            -to_addr $email \
            -from_addr [ad_system_owner] \
            -subject $subject\
            -body $body
        
        # Record that we sent email
        db_dml record_simulation_email {
            insert into sim_simulation_emails
                (simulation_id, user_id, email_type, send_date)
             values
                (:simulation_id, :user_id, 'reminder', current_timestamp)
        }
    }
}

ad_proc -public simulation::template::start {
     {-workflow_id:required}
} {
    Make a simulation go live. Does enrollment and
    casting and sets sim_type attribute to live_sim.

    @author Peter Marklund
} {
    simulation::template::get -workflow_id $workflow_id -array simulation

    if { ![string equal $simulation(sim_type) "casting_sim"] } {
        error "This simulation is in state $simulation(sim_type), it must be in 'casting_sim'"
    }

    db_transaction {
        # Change sim_type to live_sim
        set simulation_edit(sim_type) live_sim
            
        simulation::template::edit -workflow_id $workflow_id -array simulation_edit

        simulation::template::autocast -workflow_id $workflow_id
    }

    # Notify users enrolled in the simulation
    db_foreach select_enrolled_users {
            select distinct cu.user_id,
                   cu.email,
                   cu.first_names || ' ' || cu.last_name as user_name
            from sim_party_sim_map spsm,
                 cc_users cu
            where spsm.simulation_id = :workflow_id
             and spsm.type = 'enrolled'
             and spsm.party_id = cu.user_id
    } {
        # TODO: check that link to enrollment page is correct
        set package_id [ad_conn package_id]
        set simplay_url \
            [export_vars -base "[ad_url][apm_package_url_from_id $package_id]/simplay/enroll" { email }]
        set subject "Simulation $simulation(pretty_name) has started"
        set body "Dear $user_name,
Simulation $simulation(pretty_name) has now started. Please visit $simplay_url to participate. Thank you!"

        acs_mail_lite::send \
            -to_addr $email \
            -from_addr [ad_system_owner] \
            -subject $subject\
            -body $body
    }    
}

ad_proc -public simulation::template::autocast {
     {-workflow_id:required}
} {
    Takes a mapped simulation template and converts it into a cast simulation
    with simulation cases. This procedure expects to be called after enrollment is complete.

    @author Peter Marklund
} {
    # TODO (8h): also handle auto-casting when casting_type is not auto, but not all users self-cast

    simulation::template::role_party_mappings \
        -workflow_id $workflow_id \
        -array roles

    # Build user lists for each of the groups mapped to a role and calculate the total number
    # of users in the groups
    set total_users 0
    foreach role_id [array names roles] {
        array unset one_role
        array set one_role $roles($role_id)

        set role_short_name($role_id) [workflow::role::get_element -role_id $role_id -element short_name]

        foreach group_id $one_role(parties) {
            # Only create the group list once
            if { ![info exists group_members($group_id)] } { 
                set group_members($group_id) [party::approved_members -party_id $group_id -object_type user]
                set group_members($group_id) [util::randomize_list $group_members($group_id)]        
                incr total_users [llength $group_members($group_id)]
            }
        }
    }

    set workflow_short_name [workflow::get_element -workflow_id $workflow_id -element short_name]
    
    set case_counter 0

    # Create the cases and for each case assign users to roles    
    while { $total_users > 0 } {

        incr case_counter
        set sim_case_id [simulation::case::new \
                             -workflow_id $workflow_id \
                             -label "Case \#$case_counter"]
        set case_id [workflow::case::get_id \
                         -object_id $sim_case_id \
                         -workflow_short_name $workflow_short_name]

        # Assign users from the specified group for each role
        array unset row
        array set row [list]
        foreach role_id [array names roles] {
            array unset one_role
            array set one_role $roles($role_id)

            set assignees [list]
            for { set i 0 } { $i < $one_role(users_per_case) } { incr i } {
                # Get user from random group mapped to role
                set group_id [lindex [util::randomize_list $one_role(parties)] 0]

                if { [llength $group_members($group_id)] > 0 } {
                    # Add assignee
                    lappend assignees [lindex $group_members($group_id) 0]
                    # Remove the user from the group member list
                    set group_members($group_id) [lreplace $group_members($group_id) 0 0]
                    # Reduce the total_users count
                    incr total_users -1
                } else {
                    # Current group exhausted, use current user
                    lappend assignees [ad_conn user_id]
                    # Don't add the admin more than once
                    break
                }
            }

            set row($role_short_name($role_id)) $assignees
        }

        #foreach { short_name users } {
        # Remove duplicates, otherwise the call below bombs
        #    set role($short_name) [lsort -unique $role($short_name)]
        #}

        workflow::case::role::assign \
            -case_id $case_id \
            -array row \
            -replace
    }
}



#----------------------------------------------------------------------
# Simple workflow wrappers
#----------------------------------------------------------------------

ad_proc -public simulation::template::new {
    {-pretty_name:required}
    {-short_name {}}
    {-sim_type "dev_template"}
    {-suggested_duration ""}
    {-package_key:required}
    {-object_id:required}
} {
    Create a new simulation template.  

    @return The workflow_id of the created simulation.

    @author Peter Marklund
} {
    # Wrapper for simulation::template::edit
    
    foreach elm { pretty_name short_name sim_type suggested_duration package_key object_id } {
        set row($elm) [set $elm]
    }
    
    set workflow_id [simulation::template::edit \
                         -operation "insert" \
                         -array row]
                     
    return $workflow_id
}

ad_proc -public simulation::template::generate_spec {
    {-workflow_id:required}
    {-workflow_handler "simulation::template"}
    {-handlers { 
        roles "simulation::role" 
        actions "simulation::action"
        states "workflow::state::fsm"
    }}
    {-deep:boolean}
} {
    Generate a spec for a workflow in array list style.
    
    @param  workflow_id   The id of the workflow to generate a spec for.
    @return The spec for the workflow.

    @author Lars Pind (lars@collaboraid.biz)
    @see workflow::new
} {
    set spec [workflow::generate_spec \
                  -workflow_id $workflow_id \
                  -workflow_handler $workflow_handler \
                  -handlers $handlers \
                  -deep=$deep_p]

    simulation::template::get -workflow_id $workflow_id -array simulation
    
    set inner_spec [lindex $spec 1]

    lappend inner_spec suggested_duration $simulation(suggested_duration)

    set spec [lreplace $spec 1 1 $inner_spec]

    return $spec
}

ad_proc -public simulation::template::new_from_spec {
    {-package_key {}}
    {-object_id {}}
    {-spec:required}
    {-array {}}
    {-workflow_handler "simulation::template"}
    {-handlers {
        roles "simulation::role"
        states "workflow::state::fsm"
        actions "simulation::action"
    }}
} {
    Create new simulation template from a spec. Basically encodes the handlers to use.
} {
    # Wrapper for workflow::new_from_spec
    # This proc basically defines the handlers for roles, states, actions

    if { ![empty_string_p $array] } {
        upvar 1 $array row
        set array row
    } 
    return [workflow::new_from_spec \
                -package_key $package_key \
                -object_id $object_id \
                -spec $spec \
                -array $array \
                -workflow_handler $workflow_handler \
                -handlers $handlers]
}

ad_proc -public simulation::template::clone {
    {-workflow_id:required}
    {-package_key {}}
    {-object_id {}}
    {-array {}}
    {-deep:boolean}
    {-workflow_handler "simulation::template"}
} {
    Clones an existing simulation template. The clone must belong to either a package key or an object id.

    @param object_id     The id of an ACS Object indicating the scope the workflow. 
                         Typically this will be the id of a package type or a package instance
                         but it could also be some other type of ACS object within a package, for example
                         the id of a bug in the Bug Tracker application.

    @param package_key   A package to which this workflow belongs

    @param array         The name of an array in the caller's namespace. Values in this array will 
                         override workflow attributes of the workflow being cloned.

    @author Lars Pind (lars@collaboraid.biz)
    @see workflow::new
} {
    # Wrapper for workflow::clone -- only here to provide the right workflow_handler

    if { ![empty_string_p $array] } {
        upvar 1 $array row
        set array row
    } 
    
    set workflow_id [workflow::clone \
                         -deep=$deep_p \
                         -workflow_id $workflow_id \
                         -package_key $package_key \
                         -object_id $object_id \
                         -array $array \
                         -workflow_handler $workflow_handler]

    return $workflow_id
}

ad_proc -public simulation::template::get_inst_state {
    -workflow_id:required
} {
    Get information about which tab urls in the instantiation wizard
    have been completed. This proc is cached and should be flushed by the
    flush_inst_state proc whenever the instantation state changes.

    @return An array with the following keys (urls) and values either 0 or 1:

    <ul>
        simulation-edit
        map-characters
        map-tasks
        simulation-participants
        simulation-casting-3
    </ul>

    @see simulation::template::flush_inst_state
} {
    return [util_memoize [list simulation::template::get_inst_state_not_cached -workflow_id $workflow_id]]
}

ad_proc -public simulation::template::flush_inst_state {
    -workflow_id:required
} {
    Flush the instantiation state of a simulation.

    @see simulation::template::get_inst_state
} {
    util_memoize_flush [list simulation::template::get_inst_state_not_cached -workflow_id $workflow_id]
}

ad_proc -private simulation::template::get_inst_state_not_cached {
    -workflow_id:required
} {
    Internal un-cached proc invoked by get_inst_state.

    @author Peter Marklund
} {
    simulation::template::get -workflow_id $workflow_id -array sim_template    
    
    foreach tab [get_wizard_tabs] {
        set tab_complete_p($tab) 0
    }

    switch $sim_template(sim_type) {
        dev_sim {

            # 1. Settings
            if { ![empty_string_p $sim_template(case_start)] && ![empty_string_p $sim_template(send_start_note_date)] } {
                set tab_complete_p(simulation-edit) 1
            }
            
            # 2. Roles
            set role_empty_count [db_string role_empty_count {
                select count(*) 
                from   sim_roles sr,
                       workflow_roles wr
                where  sr.role_id = wr.role_id
                and    wr.workflow_id = :workflow_id
                and    character_id is null
            }]
            if { $role_empty_count == 0 } {
                set tab_complete_p(map-characters) 1
            } 

            # 3. Tasks
            set prop_empty_count [db_string prop_empty_count {
                select sum((select count(*) from sim_task_object_map where task_id = wa.action_id) - st.attachment_num)
                from   sim_tasks st,
                       workflow_actions wa
                where  st.task_id = wa.action_id
                and    wa.workflow_id = :workflow_id
            }]                
            if { $prop_empty_count == 0 } {
                set tab_complete_p(map-tasks) 1
            } 

            # 4. Participants
            set num_parties [db_string num_parties { select count(*) from sim_party_sim_map where simulation_id = :workflow_id}]
            if { [string equal $sim_template(enroll_type) "open"] || $num_parties > 0 } {
                set tab_complete_p(simulation-participants) 1
            } 
        }
        casting_sim {
            
            set n_cases [db_string select_n_cases {
                select count(*)
                from   workflow_cases
                where  workflow_id = :workflow_id
            }]

            if { $n_cases > 0 } {
                set tab_complete_p(simulation-casting-3) 1
            } 
        }
    }
    
    return [array get tab_complete_p]
}

ad_proc -public simulation::template::ready_for_casting_p {
    {-workflow_id ""}
    {-state ""}
} {
    Return 1 if the template is ready for casting and 0 otherwise.

    @author Peter Marklund
} {
    if { [empty_string_p $state] } {
        set state [get_inst_state -workflow_id $workflow_id]
    }

    array set state_array $state

    set incomplete_tabs_count 0
    foreach url [array names state_array] {
        if { !$state_array($url) } {
            incr incomplete_tabs_count
        }
    }

    return [expr $incomplete_tabs_count <= 1]
}

ad_proc -public simulation::template::get_wizard_tabs {} {
    Return a list with the url:s (page script names) of the pages
    in the instantiation wizard. 

    @author Peter Marklund
} {
    return {
        simulation-edit
        map-characters
        map-tasks
        simulation-participants
        simulation-casting-3
    }
}

ad_proc -public simulation::template::get_state_pretty {
    -state:required
} {
    Get pretty version of state.

    @see simulation::template::get_inst_state
} {
    array set state_array $state

    array set states_pretty {
        simulation-edit          "Not started"
        map-characters           "Settings completed"
        map-tasks                "Roles completed"
        simulation-participants  "Tasks completed"
        participants_complete    "Participants completed"
        simulation-casting-3     "Ready for casting"
    }
    
    set next_index 0
    foreach url [get_wizard_tabs] {
        if { $state_array($url) } {
            incr next_index
        } else {
            break
        }
    }

    return $states_pretty([lindex [get_wizard_tabs] $next_index])
}

ad_proc -public simulation::template::pretty_name_unique_p {
    -package_id:required
    -pretty_name:required
    {-workflow_id {}}
} {
    Check if suggested pretty_name is unique. 

    @return 1 if unique, 0 if not unique.
} {
    set exists_p [db_string name_exists { 
        select count(*) 
        from   workflows 
        where  package_key = 'simulation' 
        and    object_id = :package_id
        and    pretty_name = :pretty_name
        and    (:workflow_id is null or workflow_id != :workflow_id)
    }]
    return [expr !$exists_p]
}
