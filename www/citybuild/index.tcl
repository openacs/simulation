ad_page_contract {

  @creation-date 2003-10-13
  @cvs-id $Id$
} {
    parent_id:optional
    {orderby "title,asc"}
    {type:optional}
}

set page_title "CityBuild"
set context [list $page_title]
set package_id [ad_conn package_id]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

set notification_widget [notification::display::request_widget \
                             -type [simulation::notification::xml_map::type_short_name] \
                             -object_id [ad_conn package_id] \
                             -pretty_name [simulation::notification::xml_map::type_pretty_name] \
                             -url "[ad_conn url]?[ad_conn query]"]
