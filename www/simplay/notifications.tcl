ad_page_contract {
    Manage bug-tracker notifications
} {
    case_id:integer
    role_id:integer
}

simulation::case::get -case_id $case_id -array case
set case_url [export_vars -base case { case_id role_id }]

set page_title "Notifications"
set context [list [list "." "SimPlay"] [list $case_url $case(label)] $page_title]

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set return_url [ad_return_url]

multirow create notifications url label title subscribed_p

set types {workflow_assignee simplay_message}

set adminplayer_p [permission::permission_p -object_id $package_id -privilege sim_adminplayer]
if { $adminplayer_p } {
    lappend types workflow
}

foreach type $types {
    switch $type {
        workflow_assignee {
            set pretty_name "all tasks you're assigned to"
        }
        simplay_message {
            set pretty_name "all messages you receive"
        }
        workflow {
            set pretty_name "All tasks in the simulation"
        }
        default {
            error "Unknown type"
        }
    }

    # Get the type id
    set type_id [notification::type::get_type_id -short_name $type]

    # Check if subscribed
    set request_id [notification::request::get_request_id \
                        -type_id $type_id \
                        -object_id [ad_conn package_id] \
                        -user_id $user_id]

    set subscribed_p [expr ![empty_string_p $request_id]]
    
    if { $subscribed_p } {
        set url [notification::display::unsubscribe_url -request_id $request_id -url $return_url]
    } else {
        set url [notification::display::subscribe_url \
                     -type $type \
                     -object_id [ad_conn package_id] \
                     -url $return_url \
                     -user_id $user_id \
                     -pretty_name $pretty_name]
    }

    if { ![empty_string_p $url] } {
        multirow append notifications \
            $url \
            [string totitle $pretty_name] \
            [ad_decode $subscribed_p 1 "Unsubscribe from $pretty_name" "Subscribe to $pretty_name"] \
            $subscribed_p
    }
}

set manage_url "[apm_package_url_from_key [notification::package_key]]manage"
