set package_id [ad_conn package_id]
set return_url [ad_return_url]

set parameters_url [export_vars -base "/shared/parameters" {package_id return_url}]
set base_url [apm_package_url_from_id $package_id]

######################################################################
#
# Permission checking
#
######################################################################

# Anonymous users should only be allowed to access the index page (with the flash map)
# and the object view urls
# We are assuming here that all pages in the package use this master template
if { [string equal [ad_conn user_id] 0] } {
    if { ![regexp "^object/" [ad_conn extra_url]] && ![empty_string_p [ad_conn extra_url]] } {
        ad_redirect_for_registration
    }
}

set admin_p [permission::permission_p -object_id $package_id -privilege admin]
set citybuild_p [permission::permission_p -object_id $package_id -privilege sim_object_create]
set simbuild_p [permission::permission_p -object_id $package_id -privilege sim_inst]
set siminst_p [permission::permission_p -object_id $package_id -privilege sim_inst]

# If we are in any of the modules - check that the user
# has permission to be there
if { ![empty_string_p [ad_conn extra_url]] } {
    regexp {^([^/]+)} [ad_conn extra_url] dir

    set page_forbidden_p 0
    switch $dir {
        citybuild {
            if { !$citybuild_p } {
                set page_forbidden_p 1
            }
        }
        simbuild {
            if { !$simbuild_p } {
                set page_forbidden_p 1
            }

        }
        siminst {
            if { !$siminst_p } {
                set page_forbidden_p 1
            }

        }
    }

    if { $page_forbidden_p } {
        ad_return_forbidden \
            "Permission Denied" \
            "You don't have permission to access this page"
    }
}

######################################################################
#
# Build a link bar for the subsite
#
######################################################################

if { !$citybuild_p && !$simbuild_p && !$siminst_p && !$admin_p } {
    set subnavbar_link {}
} else {
    if { $citybuild_p } {
        lappend subnavbar_list [list "${base_url}citybuild" "CityBuild"]
    }

    if { $simbuild_p } {
        lappend subnavbar_list [list "${base_url}simbuild" "SimBuild"]
    }

    if { $siminst_p } {
        lappend subnavbar_list [list "${base_url}siminst" "SimInst"]
    }

    if { ![info exists header_stuff] } {
        set header_stuff {}
    }

    lappend subnavbar_list [list "${base_url}simplay" "SimPlay"]

    if { $admin_p } {
        lappend subnavbar_list [list $parameters_url Configuration] 
        lappend subnavbar_list [list "/test/admin/index?by_package_key=simulation&view_by=testcase&quiet=0" Tests]
    }

    lappend subnavbar_list [list "/doc/simulation" "Doc"]

    # TODO B: should use ad_navbar
    # couldn't figure out how to pass the input to ad_narbar so hacking it in here
    # and also added context checking
    set link_list ""
    foreach arg $subnavbar_list {
            lappend link_list "<a href=\"[lindex $arg 0]\">[lindex $arg 1]</a>"
    # removed context checking because people keep trying to use this navbar to 
    # get to the local parent, which context checking prevents
    #    if { [string match *[lindex $arg 0]* [ad_conn url]] } {
    #        lappend link_list "[lindex $arg 1]"
    #    } else {
    #        lappend link_list "<a href=\"[lindex $arg 0]\">[lindex $arg 1]</a>"
    #    }
    }
    set subnavbar_link "\[[join $link_list " | "]\]"
}
