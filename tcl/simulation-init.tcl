ad_library {
    Do initialization at server startup for the simulation package.

    @author Peter Marklund (peter@collaboraid.biz)
    @cvs-id $Id$
}

ad_schedule_proc -thread t -schedule_proc ns_schedule_daily [list 02 00] simulation::object::xml::file_sweeper

ad_schedule_proc -thread t -schedule_proc ns_schedule_daily [list 03 00] simulation::template::sweeper
