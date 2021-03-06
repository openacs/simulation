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

ad_proc simulation::casting_groups {
    {-workflow_id:required}
    {-mapped_only:boolean}
} {
    Return a list of groups eligible for enrollment and casting for a given
    workflow.

    @param workflow_id   The id of the workflow to get casting groups for.
    @param mapped_only   Provide this switch to only get groups mapped to this simulation.

    @return A list of lists, with label-id pairs, suitable to be passed
            as the options attribute of a form builder select widget.

    @author Peter Marklund
} {
    set options_list [list]

    # We only want the label and the id, i.e. strip off the count
    set groups [casting_groups_with_counts -mapped_only=$mapped_only_p -workflow_id $workflow_id]
    foreach { group_id val } $groups {
        lappend options_list [list "[lindex $val 0] ([lindex $val 1] users)" $group_id]
    }

    return $options_list
}

ad_proc simulation::casting_groups_with_counts {
    {-workflow_id:required}
    {-mapped_only:boolean}
} {
    Return a list of groups eligible for enrollment and casting for a given
    workflow.

    @param workflow_id   The id of the workflow to get casting groups for.
    @param mapped_only   Provide this switch to only get groups mapped to the simulation.


    @return A nested array lists on the format
            [list group_id1 [list group_name1 n_users1] group_id2 [list group_name2 n_users2] ...]

    @author Peter Marklund
} {
    # Lookup the application group of the subsite
    set subsite_group_id [application_group::group_id_from_package_id \
                          -package_id [ad_conn subsite_id]]

    # Get all groups related to (children of) the subsite group (only one level down)
    set enrollment_clause [ad_decode $mapped_only_p "0" "" "and  exists (select 1
                       from sim_party_sim_map
                       where party_id = g.group_id
                         and simulation_id = :workflow_id
                       )"]
    set groups_list [list]
    set permission_group_name [permission_group_name]

    db_foreach subsite_group_options "
        select g.group_name,
               g.group_id,
               (select count(*)
                       from party_approved_member_map pamm,
                            users u
                       where pamm.party_id = g.group_id
                         and pamm.member_id = u.user_id
               ) as n_users
        from   acs_rels ar,
               groups g
        where  ar.object_id_one = :subsite_group_id
          and  ar.object_id_two = g.group_id
          and  exists (select 1
                       from party_approved_member_map pamm,
                            users u
                       where pamm.party_id = g.group_id
                         and pamm.member_id = u.user_id
                      )
          and g.group_name <> :permission_group_name
          $enrollment_clause
        order by lower(g.group_name)
    " {
        lappend groups_list $group_id [list $group_name $n_users]
    }

    return $groups_list
}

ad_proc -private simulation::permission_group_name {} {
    Returns the name of the group holding all the user groups governing
    permission in the simulation package.
} {
    return "Simulation Permission Groups"
}

ad_proc -private simulation::permission_group_id {
    {-package_id ""}
} {
    Returns the id of the group holding all the user groups governing
    permission in the simulation package.

    @return The id of the permission group or

    @see simulation::permission_group_name
} {
    if { [empty_string_p $package_id] } {
        set package_id [ad_conn package_id]
    }

    set subsite_group_id [subsite_group_id -package_id $package_id]

    set permission_group_name [permission_group_name]

    # The permission group is a child of the subsite application group with a certain name
    return [db_string permission_group_id {
        select g.group_id
        from acs_rels ar,
             groups g
        where ar.object_id_one = :subsite_group_id
          and ar.object_id_two = g.group_id
          and g.group_name = :permission_group_name
    } -default ""]
}

ad_proc -private simulation::subsite_group_id {
    {-package_id ""}
} {
    if { [empty_string_p $package_id] } {
        set package_id [ad_conn package_id]
    }

    # lookup package_id of the nearest subsite
    array set package_info [site_node::get_from_object_id -object_id $package_id]
    set subsite_package_id [site_node::closest_ancestor_package -node_id $package_info(node_id) -package_key acs-subsite]
    array set closest_subsite [site_node::get_from_object_id -object_id $subsite_package_id]

    # Lookup the application group of the subsite
    set subsite_group_id [application_group::group_id_from_package_id \
                              -package_id $closest_subsite(package_id)]

    return $subsite_group_id
}

template_tag relation { params } {
    publish::process_tag relation $params
}
