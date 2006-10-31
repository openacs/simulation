ad_library {
    Simulation Case Library.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::case {}

ad_proc -public simulation::case::get {
    {-case_id:required}
    {-array:required}
} {
    Return information about a simulation case.  This is a wrapper around 
    workflow::case::get, supplementing it with the columns from sim_cases.

    @param case_id ID of simulation case.
    @param array name of array in which the info will be returned
                 Array will contain keys from the tables workflow_cases and sim_cases.
} {
    upvar $array row

    workflow::case::get -array row -case_id $case_id

    db_1row select_case {
        select sc.label,
               sc.package_id
        from sim_cases sc,
             workflow_cases wc
        where wc.case_id = :case_id
          and wc.object_id = sc.sim_case_id 
    } -column_array local_row

    array set row [array get local_row]
}

ad_proc -public simulation::case::get_element {
    {-case_id:required}
    {-element:required}
} {
    Return a single element from the information about a case.

    @param case_id     The ID of the case
    @param element     The element you want

    @return            The element you asked for

    @author Peter Marklund
} {
    get -case_id $case_id -array row
    return $row($element)
}

ad_proc -public simulation::case::new {
    {-workflow_id:required}
    {-label ""}
    {-creation_user ""}
    {-creation_ip ""}
    {-object_type "sim_case"}
} {
    Create a new simuation case for a given simulation (workflow).

    @return sim_case_id
} {
    set package_id [ad_conn package_id]

    set extra_vars [ns_set create]
    oacs_util::vars_to_ns_set \
        -ns_set $extra_vars \
        -var_list { package_id label }

    set sim_case_id [package_instantiate_object \
                         -creation_user $creation_user \
                         -creation_ip $creation_ip \
                         -package_name "sim_case" \
                         -extra_vars $extra_vars \
                         $object_type]
                     
    set case_id [workflow::case::new \
                     -workflow_id $workflow_id \
                     -object_id $sim_case_id \
                     -user_id $creation_user \
		     -no_notification]

    return $sim_case_id
}


ad_proc -public simulation::case::attachment_options {
    {-case_id:required}
    {-role_id:required}
} {
    Get labels and ids of attachments associated with the given case and role.

    @return A list of label-id pairs suitable for the options attribute of a form builder select widget.

    @author Peter Marklund
} {
    return [db_list_of_lists attachment_for_role {
        select cr.title as document_title,
               scrom.object_id as document_id
        from sim_case_role_object_map scrom,
             cr_items ci,
             cr_revisions cr
        where scrom.case_id = :case_id
          and scrom.role_id = :role_id
          and scrom.object_id = ci.item_id
          and ci.live_revision = cr.revision_id
        order by scrom.order_n
    }]
}

ad_proc -public simulation::case::assert_user_may_play_role {
    {-case_id:required}
    {-role_id:required}
} {
    Check that the currently logged in user is authorized to play a certain role
    in a simulation case. Display a permission denied page if the user is not authorized.
    Also check start dates.

    @author Peter Marklund
} {
    # If the user is an admin player he may play the role
    set package_id [ad_conn package_id]
    set adminplayer_p [permission::permission_p -object_id $package_id -privilege sim_adminplayer]    
    if { $adminplayer_p } {
        return 1
    }

	set workflow_id [workflow::case::get_element -case_id $case_id -element workflow_id]
	simulation::template::get -workflow_id $workflow_id -array simulation
    # The user is not an admin player, he needs to play the role
    set user_id [ad_conn user_id]
    set user_plays_role_p 0
    foreach assignee_list [workflow::case::role::get_assignees -case_id $case_id -role_id $role_id] {
        array set assignee $assignee_list
        if { [string equal $assignee(party_id) $user_id] } {
            set user_plays_role_p 1
            break
        }
    }

    if { !$user_plays_role_p } {
        simulation::role::get -role_id $role_id -array role
        simulation::case::get -case_id $case_id -array case_array
        ad_return_forbidden \
                "Permission Denied" \
                "<blockquote>
  You don't have permission to play role $role(pretty_name) in case $case_array(label).
</blockquote>"
        ad_script_abort
    }

	# check dates
	# we are only checking start date because there's no reason not to let people go
	# back and look around their own completed sim, e.g. to see documents
	
    if { [clock scan $simulation(case_start)] > [clock seconds] } {
        simulation::case::get -case_id $case_id -array case_array
        ad_return_forbidden \
                "Simulation hasn't started yet." \
                "<blockquote>
                	$case_array(label) doesn't start until $simulation(case_start)
</blockquote>"

        ad_script_abort
    }
    return 1
}

ad_proc -public simulation::case::complete_p {
    {-case_id:required}
} {
    Checks if the case has been completed.

    @param case_id     The ID of the case

    @return            1 if the case has been completed, 0 otherwise

    @author Jarkko Laine (jarkko@jlaine.net)
} {
    set num_enabled_actions [db_string select_num_enabled_actions {
        select count(*)
        from   workflow_case_enabled_actions
        where  case_id = :case_id
    }]

    return [expr $num_enabled_actions == 0]
}