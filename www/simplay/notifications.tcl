ad_page_contract {
    Manage bug-tracker notifications
} {
    case_id:integer
    role_id:integer
}

simulation::case::get -case_id $case_id -array case
set case_url [export_vars -base case { case_id role_id }]

set page_title [_ simulation.Notifications]

set workflow_id [simulation::case::get_element -case_id $case_id \
                   -element workflow_id]

set simulation_name [simulation::template::get_element \
                      -workflow_id $workflow_id -element pretty_name]

set sim_title [_ simulation.simulation_name]

set context [list [list . [_ simulation.SimPlay]] [list [export_vars -base case {case_id role_id }] $sim_title] $page_title]

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
            set pretty_name [_ simulation.lt_all_tasks_youre_assig]
        }
        simplay_message {
            set pretty_name [_ simulation.lt_all_messages_you_rece]
        }
        workflow {
            set pretty_name [_ simulation.lt_All_tasks_in_the_simu]
        }
        default {
            error [_ simulation.Unknown_type]
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
            [ad_decode $subscribed_p 1 [_ simulation.lt_Unsubscribe_from_pret] [_ simulation.lt_Subscribe_to_pretty_n]] \
            $subscribed_p
    }
}

set manage_url "[apm_package_url_from_key [notification::package_key]]manage"
