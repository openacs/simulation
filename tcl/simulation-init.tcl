ad_library {
    Do initialization at server startup for the simulation package.

    @author Peter Marklund (peter@collaboraid.biz)
    @cvs-id $Id$
}

ad_schedule_proc -thread t -schedule_proc ns_schedule_daily [list 02 00] simulation::object::xml::file_sweeper

# FOR DEVELOPMENT ONLY
# TODO (pm debug): remove for production:
foreach package_key {simulation workflow} {
    apm_watch_all_files $package_key
}
