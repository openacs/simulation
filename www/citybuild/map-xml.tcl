ad_page_contract {
  Display the Map XML document for this package

  @cvs-id $Id$
}

set package_id [ad_conn package_id]

permission::require_permission -object_id $package_id -privilege sim_set_map_p

ns_return 200 text/plain [simulation::object::xml::get_doc]
