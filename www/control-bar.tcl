simulation::include_contract {
    Displays a menu/control bar in simulation root directory

    @author Jarkko Laine (jarkko@jlaine.net)
    @creation-date 2004-11-25
    @cvs-id $Id$
} {
}

set package_id [ad_conn package_id]
set package_url [ad_conn package_url]

set history_url [ad_conn package_url]object/[parameter::get -package_id $package_id -parameter SieberdamHistoryFile]
set info_url [ad_conn package_url]object/[parameter::get -package_id $package_id -parameter SieberdamRocsInfoFile]
set contact_url [ad_conn package_url]object/[parameter::get -package_id $package_id -parameter ContactInformationFile]
set colophon_url [ad_conn package_url]object/[parameter::get -package_id $package_id -parameter ColophonFile]
set avail_url [ad_conn package_url]object/[parameter::get -package_id $package_id -parameter  AvailabilityInfoFile]

set citybuild_p [permission::permission_p -object_id $package_id -privilege sim_object_create]
set simbuild_p [permission::permission_p -object_id $package_id -privilege sim_template_read]
set siminst_p [permission::permission_p -object_id $package_id -privilege sim_inst]

set user [ad_conn user_id]
set notification_url "/notifications"

set curr_url [ad_conn url]