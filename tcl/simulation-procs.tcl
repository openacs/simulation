ad_library {
    API for Simulation.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation {}
namespace eval simulation::action {}
namespace eval simulation::object_type {}
namespace eval simulation::character {}
namespace eval simulation::role {}

ad_proc -public simulation::package_key {} {
    return simulation
}

ad_proc -public simulation::include_contract { args } {
    Used to define which parameters an include expecs.

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

    <p>
      TODO: Have Lars review this proc and then move it into core
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

ad_proc -public simulation::object_type::get_options {
} {
    Generate a list of object types formatted as an option list for form-builder's widgets. foo.
} {
    set sim_types { sim_character sim_prop sim_location sim_stylesheet image }

    return [db_list_of_lists object_types "
        select ot.pretty_name,
               ot.object_type
          from acs_object_types ot
         where ot.object_type in ('[join $sim_types "','"]')
    "]
}

ad_proc -public simulation::action::edit {
    {-action_id:required}
    {-sort_order {}}
    {-short_name:required}
    {-pretty_name:required}
    {-pretty_past_tense {}}
    {-edit_fields {}}
    {-allowed_roles {}}
    {-assigned_role {}}
    {-privileges {}}
    {-enabled_states {}}
    {-assigned_states {}}
    {-new_state {}}
    {-callbacks {}}
    {-always_enabled_p f}
    {-initial_action_p f}
    {-recipient_role:required {}}
    {-description {}}
    {-description_mime_type {}}
} {
    Edit an action.  Mostly a wrapper for fsm, plus some simulation-specific stuff.
} {

    # should call API, but API doesn't exist yet
    # deferring at the moment since we're only changing two fields in this
    # prototype UI anyway.  But it would look like this:

    #    workflow::action::fsm::edit \
    #       -workflow_id $workflow_id
    #      -short_name $name \
    #       -pretty_name $name \
    #       -assigned_role $assigned_role

    set workflow_id [workflow::action::get_workflow_id -action_id $action_id]

    db_transaction {
        db_dml edit_workflow_action {
            update workflow_actions
               set short_name = :short_name,
                   pretty_name = :pretty_name,
                   assigned_role = :assigned_role,
                   description = :description,
                   description_mime_type = :description_mime_type
             where action_id = :action_id
        }

        db_dml edit_sim_role {
            update sim_tasks
               set recipient = :recipient_role
             where task_id = :action_id
        }
    }

    workflow::action::flush_cache -workflow_id $workflow_id
}

template_tag relation { params } {
    publish::process_tag relation $params
}

################################
#
# simulation::character namespace
#
################################

ad_proc -public simulation::character::get {
    {-character_id:required}
    {-array:required}
} {
    Get basic information about a character. Gets the following attributes: uri, title.

    @param  array       The name of an array into which you want the information put. 

    @author Peter Marklund
} {
    upvar $array row

    db_1row select_character_info {} -column_array row
}

ad_proc -public simulation::character::get_element {
    {-character_id:required}
    {-element:required}
} {
    Get a particular attribute from a character object.

    @param element Name of the attribute you want to retrieve

    @see simulation::character::get

    @author Peter Marklund
} {
    get -character_id $character_id -array character

    return $character($element)
}

################################
#
# simulation::role namespace
#
################################

ad_proc -public simulation::role::new {
    {-template_id:required}
    {-character_id:required}
    {-role_short_name ""}
    {-role_pretty_name ""}
} {
    Create a new simulation role for a given simulation template
    and character. Will map the character to the template if this
    is not already done.

    @author Peter Marklund
} {
    # Set default values for names
    if { [empty_string_p $role_short_name] || [empty_string_p $role_pretty_name] } {
        set character_name [simulation::character::get_element \
                                -character_id $character_id \
                                -element title]
    }
    if { [empty_string_p $role_short_name] } {
        set role_short_name $character_name
    }
    if { [empty_string_p $role_pretty_name] } {
        set role_pretty_name $character_name
    }

    db_transaction {
        simulation::template::associate_object \
            -template_id $template_id \
            -object_id $character_id

        # create the role
        set role_id [workflow::role::new \
                         -workflow_id $template_id \
                         -short_name $role_short_name \
                         -pretty_name $role_pretty_name]
        # and then add extra data for simulation
        db_dml set_role_character {
            insert into sim_roles
            values (:role_id, :character_id)
        }    
    }
}

ad_proc -public simulation::role::delete {
    {-role_id:required}
} {
    workflow::role::delete -role_id $role_id
}
