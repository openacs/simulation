set package_id [ad_conn package_id]
set return_url [ad_return_url]

set parameters_url [export_vars -base "/shared/parameters" {package_id return_url}]
set base_url [apm_package_url_from_id $package_id]

######################################################################
#
# Build a link bar for the subsite
#
######################################################################

set admin_p [permission::permission_p -object_id $package_id -privilege admin]
set citybuild_p [permission::permission_p -object_id $package_id -privilege sim_object_create]
set simbuild_p [permission::permission_p -object_id $package_id -privilege sim_object_create]
set siminst_p [permission::permission_p -object_id $package_id -privilege sim_inst]

if { $citybuild_p } {
    lappend subnavbar_list [list "${base_url}citybuild" "CityBuild"]
}

if { $simbuild_p } {
    lappend subnavbar_list [list "${base_url}simbuild" "SimBuild"]
}

if { $siminst_p } {
    lappend subnavbar_list [list "${base_url}siminst" "SimInst"]
}

lappend subnavbar_list [list "${base_url}simplay" "SimPlay"]

if { $admin_p } {
    lappend subnavbar_list [list $parameters_url Configuration] 
    lappend subnavbar_list [list "/test/admin/index?by_package_key=simulation&view_by=testcase&quiet=0" Tests]
}

lappend subnavbar_list [list "/doc/simulation" "Doc"]

# TODO: should use ad_navbar
# couldn't figure out how to pass the input to ad_narbar so hacking it in here
# and also added context checking
set link_list ""
foreach arg $subnavbar_list {
    if { [string match *[lindex $arg 0]* [ad_conn url]] } {
        lappend link_list "[lindex $arg 1]"
    } else {
        lappend link_list "<a href=\"[lindex $arg 0]\">[lindex $arg 1]</a>"
    }
}
set subnavbar_link "\[[join $link_list " | "]\]"
