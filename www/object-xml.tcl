ad_page_contract {
    Show flash xml for a simulation object.

    @creation-date 2003-11-07
    @cvs-id $Id$
} {
    item_id:integer
}

set flash_xml [simulation::object::generate_xml -item_id $item_id]

ns_return 200 text/plain $flash_xml
