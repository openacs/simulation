ad_library {
    Installation, instantiation, etc. procs

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-13
    @cvs-id $Id$
}

namespace eval simulation::apm {}


ad_proc -private simulation::apm::after_instantiate {
    {-package_id:required}
} {
    Create the package root folder.
} {
    set instance_name [apm_instance_name_from_id $package_id]
    
    set folder_id [bcms::folder::create_folder \
                       -name "simulation_${package_id}_root" \
                       -folder_label "${instance_name} Root" \
                       -parent_id 0 \
                       -package_id $package_id \
                       -content_types { sim_character sim_prop sim_home sim_contact file_storage_object }]
}

