ad_page_contract {
  Generate map XML file for this package.

  @cvs-id $Id$
}

set page_title "Generation of Map XML file"
set context [list [list object-list "Object List"] $page_title]

array set result [simulation::object::xml::generate_file -package_id [ad_conn package_id]]

set error_text [join $result(errors) "\n"]
