# Procs to support the Tclwebtest (HTTP level) testing and demo data setup
# of the simulation package.
#
# @author Peter Marklund

namespace eval ::twt::simulation {}

ad_proc ::twt::simulation::get_object_short_name { name } {
    set short_name [string tolower $name]
    regsub -all {\s} $short_name {-} short_name

    return $short_name
}

ad_proc ::twt::simulation::add_image {
    {-title:required}
    {-description ""}
    {-content_file:required}
} {
    Create a new simulation image
} {
    do_request /simulation/citybuild
    link follow ~u object-edit

    # Choose object type image
    set_object_form_type image
    
    foreach input_name {title description content_file} {
        field fill [set $input_name] ~n $input_name
    }
    form submit
}

ad_proc ::twt::simulation::set_object_form_type { type } {
    form find ~n object
    field find ~n content_type
    field select2 ~v $type
    field find ~n __refreshing_p
    field fill 1
    form submit
}

ad_proc ::twt::simulation::add_object {
    {-type:required}
    {-title:required}
} {
    Create a new simulation object
} {
    do_request /simulation/citybuild
    link follow ~u object-edit

    set_object_form_type $type

    form find ~n object
    field find ~n title
    field fill $title
    form submit
}

ad_proc ::twt::simulation::visit_template_page { template_name } {

    do_request /simulation/simbuild/
    link follow ~u template-edit ~c $template_name    
}

ad_proc ::twt::simulation::add_user {
    {-first_names:required}
    {-last_name:required}
} {
    do_request /acs-admin/users/user-add
    field find ~n email
    set email [email_from_user_name "$first_names $last_name"]
    field fill $email
    field find ~n first_names
    field fill $first_names
    field find ~n last_name
    field fill $last_name
    field find ~n password
    field fill [::twt::user::get_password $email]
    field find ~n password_confirm
    field fill [::twt::user::get_password $email]

    form submit
}

ad_proc ::twt::simulation::email_from_user_name { user_name } {
    set email_account [string map {" " _} $user_name]
    set email "${email_account}@test.test"

    return $email
}

ad_proc ::twt::simulation::permission_user_email { group_name } {
    Given the name of one of the permission groups, i.e. "Sim Admins",
    return the email of the demo user in that group.
} {
    return [email_from_user_name "[permission_user_first_names $group_name] [permission_user_last_name $group_name]"]
}

ad_proc ::twt::simulation::permission_user_first_names { group_name } {
    Given the name of one of the permission groups, i.e. "Sim Admins",
    return the first names of the demo user in that group.
} {
    return $group_name
}

ad_proc ::twt::simulation::permission_user_last_name { group_name } {
    Given the name of one of the permission groups, i.e. "Sim Admins",
    return the last name of the demo user in that group.
} {
    return "Test User"
}

ad_proc ::twt::simulation::add_user_to_group_url {
    {-group_name:required}
} {
    do_request "/admin/group-types/one?group_type=group"
    link follow ~c $group_name
    
    link follow ~u "relations/add.*membership_rel"        
    link follow ~u "membership_rel"

    set add_user_url $::tclwebtest::url

    return $add_user_url
}

ad_proc ::twt::simulation::add_user_to_group {
    {-group_name ""}
    {-add_user_url ""}
    {-user_name:required}
} {
    if { [empty_string_p $add_user_url] } {
        set add_user_url [add_user_to_group_url -group_name $group_name]
    }

    do_request $add_user_url
    field find ~n party_id
    field select $user_name
    form submit    
}

ad_proc ::twt::simulation::get_template_spec {} {
    return "simulatie_tilburg {
    description {Use case 1 template from Leiden team.}
    description_mime_type text/enhanced
    object_type acs_object
    package_key simulation
    pretty_name {
        Simulation Tilburg
    }
    roles {
        lawyer {
            pretty_name Lawyer
        }
        client {
            pretty_name Client
        }
        other_lawyer {
            pretty_name {
                Other lawyer
            }
        }
        other_client {
            pretty_name {
                Other client
            }
        }
        mentor {
            pretty_name Mentor
        }
        secretary {
            pretty_name Secretary
        }
    }
    actions {
        initialize {
            initial_action_p t
            new_state started
            pretty_name Initialize
            attachment_num 0
        }
        ask_client {
            assigned_role lawyer
            assigned_states started
            new_state open
            pretty_name {
                Ask client
            }
            attachment_num 1
            recipient_role client
        }
        ask_client_for_more_information {
            assigned_role lawyer
            enabled_states open
            pretty_name {Ask Client for more information}
            attachment_num 1
            recipient_role client
        }
        consult_lawyer {
            assigned_role lawyer
            enabled_states open
            pretty_name {
                Consult lawyer
            }
            attachment_num 1
            recipient_role other_lawyer
        }
        visit_the_library {
            assigned_role lawyer
            enabled_states open
            pretty_name {Visit the library}
            attachment_num 0
            recipient_role lawyer
        }
        consult_mentor {
            assigned_role lawyer
            enabled_states open
            pretty_name {
                Consult mentor
            }
            attachment_num 1
            recipient_role mentor
        }
        mentor_intervenes {
            assigned_role mentor
            enabled_states open
            pretty_name {
                Mentor intervenes
            }
            attachment_num 1
            recipient_role lawyer
        }
        consult_secretary {
            assigned_role lawyer
            enabled_states open
            pretty_name {
                Consult secretary
            }
            attachment_num 1
            recipient_role secretary
        }
        write_legal_advice {
            assigned_role lawyer
            assigned_states open
            new_state written
            pretty_name {Write legal advice}
            attachment_num 1
            recipient_role secretary
        }
        correct_spell_check_etc {
            assigned_role secretary
            enabled_states written
            new_state done
            pretty_name {Correct, spell-check, etc.}
            attachment_num 1
            recipient_role client
        }
    }
    states {
        started {
            pretty_name Started
        }
        open {
            pretty_name Open
        }
        written {
            pretty_name Written
        }
        done {
            pretty_name Done
        }
    }
}"
}

ad_proc ::twt::simulation::add_template {
    {-template_name:required}
} {
    do_request /simulation/simbuild/template-edit
    form find ~n sim_template    
    field fill $template_name ~n name
    form submit
}

ad_proc ::twt::simulation::add_roles_to_template {
    {-template_name:required}
    {-character_array:required}
} {
    upvar $character_array characters

    ::twt::simulation::visit_template_page $template_name 
    link follow ~u role-edit
    set add_role_url [response url]
    foreach character_name [array names characters] {
        do_request $add_role_url
        form find ~n role
        field find ~n name
        field fill $characters($character_name)
        form submit
    }
}

ad_proc ::twt::simulation::add_tasks_to_template {
    {-template_name:required}
    {-task_array:required}
} {
    upvar $task_array tasks

    ::twt::simulation::visit_template_page $template_name 

    link follow ~u task-edit
    set add_task_url [response url]

    foreach task_name [array names tasks] {
        array set task $tasks($task_name)
        do_request $add_task_url
        form find ~n task
        field find ~n name 
        field fill $task_name
        field find ~n assigned_role
        field select $task(assigned_role)
        field find ~n recipient_role        
        field select $task(recipient_role)
        field find ~n description 
        field fill "This is the task description for task $task_name"
        form submit
    }
}

ad_proc ::twt::simulation::assert_page_accessible {url} {
    Access the given url and throw an error if it's not accessible.

    @see ::twt::simulation::page_accessible_p
} {
    if { ![page_accessible_p $url] } {
        error "The page at url $url should be accessible but doesn't seem to be (status=[response status] response_url=[response url])"
    }
}

ad_proc ::twt::simulation::assert_page_not_accessible {url} {
    Access the given url and throw an error if it's accessible.

    @see ::twt::simulation::page_accessible_p
} {
    if { [page_accessible_p $url] } {
        error "The page at url $url should not be accessible but seems to be (status=[response status] response_url=[response url])"
    }
}

ad_proc ::twt::simulation::page_accessible_p {url} {
    Access the given url and return 1 if there is no permission violation,
    breakage, or redirection. Returns 0 otherwise.
} {
    # Tclwebtest will throw an error for status 403 and this catch is a workaround for that
    catch {do_request $url}

    return [expr [string equal [response status] 200] && \
                [regexp $url [response url]] && \
                ![regexp "Permission Denied" [response body]]]
}
