ad_library {
    API for Simulation.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation {}
namespace eval simulation::action {}
namespace eval simulation::object_type {}
namespace eval simulation::template {}
namespace eval simulation::character {}
namespace eval simulation::role {}

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
