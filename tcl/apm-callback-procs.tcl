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
                       -content_types { sim_character sim_prop sim_location sim_stylesheet image }]

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
