ad_library {
    Installation, instantiation, etc. procs

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-13
    @cvs-id $Id$
}

namespace eval simulation::apm {}

ad_proc -private simulation::apm::after_install {} {
    simulation::notification::xml_map::register
}

ad_proc -private simulation::apm::before_uninstall {} {
    simulation::notification::xml_map::unregister
}

ad_proc -private simulation::apm::after_instantiate {
    {-package_id:required}
} {
    Create data associated with a simulation package instance.
} {
    set instance_name [apm_instance_name_from_id $package_id]
    
    set folder_id [bcms::folder::create_folder \
                       -name "simulation_${package_id}_root" \
                       -folder_label "${instance_name} Root" \
                       -parent_id 0 \
                       -package_id $package_id \
                       -context_id $package_id \
                       -content_types { sim_character sim_prop sim_location sim_stylesheet image sim_message }]

    application_group::new \
        -group_name "Simulation Test Class" \
        -package_id $package_id
}

ad_proc -private simulation::apm::before_uninstantiate {
    {-package_id:required}
} {
    Tear down data associated with a package instance.
} {
    set folder_id [bcms::folder::get_id_by_package_id -parent_id 0]   
    bcms::folder::delete_folder -folder_id $folder_id

    set group_id [application_group::group_id_from_package_id -package_id $package_id]
    group::delete $group_id
}

ad_proc -private simulation::apm::after_mount {
    {-package_id:required}
    {-node_id:required}
} {
    Executed by APM after a simulation package instance has been mounted.
} {
    setup_permission_groups -package_id $package_id
} 

ad_proc -private simulation::apm::setup_permission_groups {
    {-package_id:required}
} {
    Set up subsite groups related to permissions.
} {
    # Only setup the groups if they don't already exist
    set existing_parent_group [simulation::permission_group_id -package_id $package_id]    
    if { [empty_string_p $existing_parent_group] } {        
        # Create a new permission group
        set parent_group_id [group::new -group_name [simulation::permission_group_name]]

        # Make permission group a child of the subsite group
        set subsite_group_id [simulation::subsite_group_id -package_id $package_id]
        relation_add composition_rel $subsite_group_id $parent_group_id

        # Create the permission groups
        foreach {group_name privilege_list} {
            "Sim Admins" {sim_admin}
            "Template Authors" {sim_template_creator sim_inst sim_object_create}
            "Case Authors" {sim_inst sim_object_create sim_adminplayer}
            "Service Admins" {}
            "City Admins" {sim_set_map_p sim_object_writer}
            "Actors" {}
        } {
            set permission_group_id [group::new -group_name $group_name]

            # Make permission group a child of the parent group
            relation_add composition_rel $parent_group_id $permission_group_id

            # Grant privileges to the group
            foreach privilege $privilege_list {
                permission::grant -party_id $permission_group_id -object_id $package_id -privilege $privilege
            }
        }
    }
} 

ad_proc -private simulation::apm::before_unmount {
    {-package_id:required}
    {-node_id:required}
} {
    Executed by the APM before a simulation package instance is unmounted.
} {
    teardown_permission_groups -package_id $package_id
} 

ad_proc -private simulation::apm::teardown_permission_groups {
    {-package_id:required}
} {
    Teardown subsite groups related to permissions.
} {
    # Only attempt teardown if groups exist
    set existing_parent_group [simulation::permission_group_id -package_id $package_id]    
    if { ![empty_string_p $existing_parent_group] } {
        # Delete the children first
        set child_groups [db_list permission-groups {
            select object_id_two
            from acs_rels
            where object_id_one = :existing_parent_group
              and rel_type = 'composition_rel'
        }]

        foreach child_group $child_groups {
            group::delete $child_group
        }

        # Delete the parent
        group::delete $existing_parent_group
    }
}
