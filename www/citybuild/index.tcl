ad_page_contract {

  @creation-date 2003-10-13
  @cvs-id $Id$
} {
    parent_id:optional
    orderby:optional
    type:optional
}

set page_title "CityBuild"
set context [list $page_title]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]

set help_url "${package_url}object/[parameter::get -package_id $package_id -parameter CityBuildHelpFile]"

permission::require_permission -object_id $package_id -privilege sim_object_create

set admin_p [permission::permission_p -object_id $package_id -privilege admin]
set map_p [permission::permission_p -object_id $package_id -privilege sim_set_map_p]


foreach { subscribe_url unsubscribe_url } \
    [notification::display::get_urls \
         -type [simulation::notification::xml_map::type_short_name] \
         -object_id [ad_conn package_id] \
         -pretty_name [simulation::notification::xml_map::type_pretty_name]] {}
