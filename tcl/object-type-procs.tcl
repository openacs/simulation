ad_library {
    API for Simulation object types.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::object_type {}

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
