ad_library {
    API for Simulation.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation {}

ad_proc -public simulation::package_key {} {
    return simulation
}

ad_proc -public simulation::include_contract { args } {
    Used to define which parameters an include expecs.

    <p>
      NOTE: This proc is to be replaced with a refactored ad_page_contract that
      can function for includes. Lars knows more.
    </p>

    @param args A list where the first element is an explanation of what the
                include does, who wrote it when etc. The second element is the optional
                param spec which is an array list where the keys are parameter (variable)
                names and the values are array lists where the keys
                are parameter attributes. Examples below.

    <pre>
      simulation::include_contract {
          Displays a list of templates

          @author Joel Aufrecht
          @creation-date 2003-11-12
          @cvs-id $Id$
       } {
           display_mode {
               allowed_values {edit display}
               default_value display
           }
           size {
               allowed_values {short long}
               default_value long
           }
       }     
    </pre>

    <pre>
      simulation::include_contract {
          A list of all objects associated with the Simulation Template

          @author Joel Aufrecht
          @creation-date 2003-11-12
          @cvs-id $Id$
      } {
          workflow_id {}
      }     
    </pre>

    <p>
      The following attributes can be used for parameters:

      <ul>
        <li>required_p - Is there parameter required? Defaults to 1. Note that if the parameter has a default
                         value that means it is not required.</li>
        <li>allowed_values - A list of values that are valid for the parameter. Empty by default, meaning all values are valid.</li>
        <li>default_value - Any value that the parameter should default to.</li>
      </ul>
    </p> 

    @author Peter Marklund
} {
    set description [lindex $args 0]
    if { [llength $args] == 1 } {
        # No spec
        return
    }

    set spec [lindex $args 1]
    array set spec_array $spec

    foreach param_name [array names spec_array] {
        array unset param_array
        array set param_array $spec_array($param_name)

        upvar $param_name param

        if { ![info exists param_array(required_p)] } {
            set param_array(required_p) 1
        }
        
        # Set default values
        if { ![info exists param] && [info exists param_array(default_value)] } {
            set param $param_array(default_value)
        }
        
        # Check required params are there
        if { [string equal $param_array(required_p) 1] && ![info exists param] } {
            error "Required parameter $param_name not provide to include"
        }    

        # Check param has valid value
        if { [info exists param] && [info exists param_array(allowed_values)] } {
            if { [lsearch -exact $param_array(allowed_values) $param] == -1 } {
                error "Parameter $param_name passed to include has invalid value \"$param\". Valid values are: [join $param_array(allowed_values) ", "]"
            }
        }   
    }
}

ad_proc simulation::get_object_options { 
    {-content_type:required}
} {
    Returns a list of cr_revision.title, cr_item.item_id pairs
    for all cr_items of the given content_type in the root
    folder of the current package. Suitable for ad_form options for
    select boxes.

    @return [list [list cr_revision.title1 cr_item.item_id1] [list cr_revision.title2 cr_item.item_id2] ....]

    @author Peter Marklund
} {
    set package_id [ad_conn package_id]
    set parent_id [bcms::folder::get_id_by_package_id -package_id $package_id]

    return [db_list_of_lists character_options {
        select cr.title,
               ci.item_id
        from cr_items ci,
             cr_revisions cr
        where ci.live_revision = cr.revision_id
        and ci.parent_id = :parent_id
        and ci.content_type = :content_type
    }]
}

ad_proc -public simulation::cast {
    {-workflow_id:required}
    {-pretty_name:required}
    {-actors:required}
    {-groupings:required}
} {
    Takes a mapped simulation template and creates a casted simulation
    with simulation cases. It does this by cloning the simulation
    template.

    TODO: agent support

    TODO: taking actor type into account

    @param actors An array list with the actors of the simulation. The keys
                  of the list are role_ids and the values ids of the actor to play the role.
    @param groups An array list with the groupings of the simulation. The keys
                  of the list are role_ids and the values are integers indicaing
                  a number of users to play that role.

    @return workflow_id of the simulation created.

    @author Peter Marklund
} {
    array set actors_array $actors
    array set groupings_array $groupings

    # TODO: make sure this is a proper clone also after mapping (tasks and characters...)
    set workflow_id [simulation::template::clone \
                         -pretty_name $pretty_name \
                         -workflow_id $workflow_id]

    set user_list [db_list select_users {
        select member_id
        from party_approved_member_map
        where party_id in (select
                           party_id from sim_party_sim_map
                           where simulation_id = :workflow_id
                           )
    }]
    set total_n_users [llength $user_list]

    set n_users_per_case 0
    foreach role_id [array names groupings_array] {
        set n_users_per_case [expr $n_users_per_case + $groupings_array($role_id)]
    }

    set mod_n_users [expr $total_n_users % $n_users_per_case]
    set n_cases [expr ($total_n_users - $mod_n_users) / $n_users_per_case]


    if { $mod_n_users == "0" } {
        # No rest in dividing, the cases add up nicely
        
    } else {
        # We are missing mod_n_users to fill up the simulation. Create a new simulation
        # for those students.
        set n_cases [expr $n_cases + 1]
    }

    # Create the cases and for each case assign roles to parties
    set users_start_index 0
    for { set case_counter 0 } { $case_counter < $n_cases } { incr case_counter } {
        # TODO: what should object_id be here?
        set object_id [ad_conn package_id]
        set case_id [workflow::case::new \
                         -workflow_id $workflow_id \
                         -object_id $object_id]

        # Assign a group of users to each role in the case
        set party_array_list [list]
        foreach role_id [array names actors] {
            set role_short_name [workflow::role::get_element -role_id $role_id -element short_name]

            set users_end_index [expr $users_start_index + $groupings_array($role_id) - 1]

            set parties_list [lrange $user_list $users_start_index $users_end_index]

            lappend parties_array_list $role_short_name $users_list

            set users_start_index [expr $users_end_index + 1]
        }

        workflow::case::role::assign \
            -case_id $case_id \
            -array $party_array_list \
            -replace
    }

    return $workflow_id
}

template_tag relation { params } {
    publish::process_tag relation $params
}
