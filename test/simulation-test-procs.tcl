# Procs to support the Tclwebtest (HTTP level) testing and demo data setup
# of the simulation package.
#
# @author Peter Marklund

namespace eval ::twt::simulation {}
namespace eval ::twt::simulation::setup {}
namespace eval ::twt::simulation::test {}
namespace eval ::twt::simulation::play {}

##############################
#
# ::twt::simulation::setup procs
#
##############################

ad_proc ::twt::simulation::setup::users_and_groups {} {

    ::twt::log_section "Login site-wide admin"
    ::twt::user::login_site_wide_admin

    ::twt::log_section "Add demo users to system"
    for {set i 1} {$i <= 20} {incr i} {
        ::twt::simulation::add_user -first_names Demo -last_name "User $i"
    }    

    ::twt::log_section "Add demo groups"
    for {set i 1} {$i <= 5} {incr i} {
        do_request "/admin/group-types/one?group_type=group"
        link follow ~u "parties/new"

        field find ~n group.group_name
        field fill "Demo group $i"
        form submit
    }
    
    ::twt::log_section "Add demo users to groups"
    for {set i 1} {$i <= 5} {incr i} {
        
        set add_user_url [::twt::simulation::add_user_to_group_url -group_name "Demo group $i"]

        for {set user_count [expr ($i - 1)*4 + 1]} {$user_count <= [expr $i*4]} {incr user_count} {
            ::twt::simulation::add_user_to_group -add_user_url $add_user_url -user_name "Demo User $user_count"
        }
    }

    ::twt::log_section "Create a demo user in each permission group"
    foreach group_name {
        "Sim Admins"
        "Template Authors"
        "Case Authors"
        "Service Admins"
        "City Admins"
        "Actors"
    } {
        set first_names [::twt::simulation::permission_user_first_names $group_name]
        set last_name [::twt::simulation::permission_user_last_name $group_name]
        ::twt::simulation::add_user -first_names $first_names -last_name $last_name

        ::twt::simulation::add_user_to_group -group_name $group_name -user_name "$first_names $last_name"
    }
}

ad_proc ::twt::simulation::setup::citybuild_objects {} {

    # Do this as the city build user to make sure he has sufficient permissions
    ::twt::log_section "Login city admin"
    ::twt::user::login [::twt::simulation::permission_user_email "City Admins"]

    ::twt::log_section "Create an image object"
    do_request /simulation/citybuild
    link follow ~u object-edit
    form find ~n object
    field find ~n content_type
    field select2 ~v image
    field find ~n __refreshing_p
    field fill 1
    form submit    
    field find ~n title
    field fill "New Jersey Lawyers"
    field find ~n description
    field fill "New Jersey Lawyers and Consumers"
    field find ~n content_file
    field fill [::twt::config::serverroot]/packages/simulation/test/new-jersey-lawyer-logo.gif
    form submit

    ::twt::log_section "Create characters for Elementary private law"
    array set characters [::twt::simulation::data::characters]
    foreach character_name [array names characters] {
        ::twt::simulation::add_object -type character -title $character_name
    }

    ::twt::log_section "Create characters for Legislative Drafting"
    array set characters_ld [::twt::simulation::data::characters_ld]
    foreach character_name [array names characters_ld] {
        ::twt::simulation::add_object -type character -title $character_name
    }

    ::twt::log_section "Create properties"
    array set properties [::twt::simulation::data::properties]
    foreach property_name [array names properties] {
        ::twt::simulation::add_object -type sim_prop -title $property_name
    }
}

ad_proc ::twt::simulation::setup::all_templates {} {

    ::twt::simulation::setup::elementary_private_law_template   
    ::twt::simulation::setup::legislative_drafting_template
    ::twt::simulation::setup::tilburg_template_from_spec    
    # TODO: click the ready_p link for the templates
}

ad_proc ::twt::simulation::setup::elementary_private_law_template {} {

    # Do this as the template author to make sure he has sufficient permissions
    ::twt::log_section "Login template author"
    ::twt::user::login [::twt::simulation::permission_user_email "Template Authors"]

    set template_name "Elementary Private Law"
    ::twt::log_section "Create $template_name simulation template"
    ::twt::simulation::add_template -template_name $template_name

    ::twt::log_section "Create roles for template"
    ::twt::simulation::add_roles_to_template \
        -template_name $template_name \
        -characters_list [::twt::simulation::data::characters]

    ::twt::log_section "Add tasks to template"
    ::twt::simulation::add_tasks_to_template \
        -template_name $template_name \
        -tasks_list [::twt::simulation::data::tasks]
}

ad_proc ::twt::simulation::setup::legislative_drafting_template {} {

    # Do this as the sim admin to make sure he has sufficient permissions
    ::twt::log_section "Login sim admin"
    ::twt::user::login [::twt::simulation::permission_user_email "Sim Admins"]

    set template_name "Legislative Drafting"
    ::twt::log_section "Create $template_name simulation template"
    ::twt::simulation::add_template -template_name $template_name

    ::twt::log_section "Create roles for template"
    ::twt::simulation::add_roles_to_template \
        -template_name $template_name \
        -characters_list [::twt::simulation::data::characters_ld]

    ::twt::log_section "Add tasks to template"
    ::twt::simulation::add_tasks_to_template \
        -template_name $template_name \
        -tasks_list [::twt::simulation::data::tasks_ld]
}

ad_proc ::twt::simulation::setup::tilburg_template_from_spec {} {

    # Do this as the template author to make sure he has sufficient permissions
    ::twt::log_section "Login template author"
    ::twt::user::login [::twt::simulation::permission_user_email "Template Authors"]

    ::twt::log_section "Create a template from a spec"
    do_request /simulation/simbuild/template-load
    set template_name "Template loaded from spec"
    field fill $template_name ~n pretty_name
    field fill [::twt::simulation::data::tilburg_template_spec] ~n spec
    form submit

    do_request /simulation/simbuild
    link follow ~c $template_name
    link follow ~u template-sim-type-update

    ::twt::log_section "Login case author"
    ::twt::user::login [::twt::simulation::permission_user_email "Case Authors"]
    
    ::twt::log_section "Instantiate the Tilburg template"
    do_request /simulation/siminst/simulation-new
    link follow ~u map-create
    
    form find ~n template
    # Make name unique
    set unique_name "New Simulation from Template loaded from spec [expr rand()]"
    field fill $unique_name ~n pretty_name
    form submit

    # Wizard page 1 - Settings
    form find ~n simulation
    form submit

    regexp {workflow_id=([0-9]+)} [response url] match workflow_id

    # Wizard page 2 - Roles
    form find ~n characters
    form submit ~n next

    # Wizard page 3 - Tasks
    form find ~n tasks
    # Get number of task attachments we need to set
    set number_of_attachments 0
    array set tilburg_spec [lindex [::twt::simulation::data::tilburg_template_spec] 1]
    array set actions $tilburg_spec(actions)
    foreach action_name [array names actions] {
        array set action $actions($action_name)
        incr number_of_attachments $action(attachment_num)
    }
    # Select the attachments (using the first property)
    for { set i 1 } { $i <= $number_of_attachments } { incr i } {
        field find -next ~n {attachment_[0-9]}
        field select [lindex [::twt::simulation::data::properties] 0]
    }
    form submit ~n next

    # Wizard page 4 - Participants
    form find ~n simulation
    field find ~n __group_ ~t radio
    field select2 ~v "auto_enroll"
    field find -next ~n __group_ ~t radio
    field select2 ~v "auto_enroll"
    field find -next ~n __group_ ~t radio
    field select2 ~v "invited"
    field find -next ~n __group_ ~t radio
    field select2 ~v "invited"
    form submit ~n next

    # Wizard page 5 - Casting
    form find ~n actors
    field find ~n parties_ ~t checkbox
    field check
    field find -next ~n parties_ ~t checkbox
    field check
    field find -next ~n parties_ ~t checkbox
    field check
    field find -next ~n parties_ ~t checkbox
    field check
    field find -next ~n parties_ ~t checkbox
    field check
    field find -next ~n parties_ ~t checkbox
    field check
    form submit ~n finish

    do_request /simulation/siminst/simulation-start?workflow_id=$workflow_id
}

##############################
#
# ::twt::simulation::test procs
#
##############################

ad_proc ::twt::simulation::test::permissions_all {} {

    ::twt::simulation::test::permissions_anonymous
    ::twt::simulation::test::permissions_city_admin
    ::twt::simulation::test::permissions_sim_admin
    ::twt::simulation::test::permissions_template_author
    ::twt::simulation::test::permissions_case_author
    ::twt::simulation::test::permissions_service_admin
    ::twt::simulation::test::permissions_actor
}

ad_proc ::twt::simulation::test::permissions_anonymous {} {

    ::twt::log_section "Permission testing with anonymous user"
    ::twt::user::logout

    # The anonymous user can access the index page with the flash map
    ::twt::simulation::assert_page_accessible /simulation

    # TODO: Should see a list of all simulation open for enrollment

    # The anonymous user can access an object view page
    ::twt::simulation::assert_page_accessible /simulation/object/motorhome

    # The anonymous user can not access any of the four modules
    foreach disallowed_url {simplay siminst simbuild citybuild} {
        do_request /simulation/$disallowed_url
        if { ![regexp {/register/} $::tclwebtest::url] } {
            error "Anonymous user was not redirected to login page for url $disallowed_url"
        }
    }
}

ad_proc ::twt::simulation::test::permissions_city_admin {} {

    set group_name "City Admins"
    ::twt::log_section "Permission testing for $group_name user"
    ::twt::user::login [::twt::simulation::permission_user_email $group_name]

    # city admin can access index page
    ::twt::simulation::assert_page_accessible /simulation

    # can access citybuild
    ::twt::simulation::assert_page_accessible /simulation/citybuild

    # can create, edit on_map_p, and delete object
    ::twt::simulation::create_edit_delete_property

    # can not build or instantiate templates
    foreach module {simbuild siminst} {
        ::twt::simulation::assert_page_not_accessible /simulation/$module
    }
}

ad_proc ::twt::simulation::test::permissions_sim_admin {} {

    set group_name "Sim Admins"
    ::twt::log_section "Permission testing for $group_name user"
    ::twt::user::login [::twt::simulation::permission_user_email $group_name]

    # can do anything within the package
    # including the on_map_p attribute

    # We've already done some testing with the sim admin in the template setup

    # Access each module
    foreach module {citybuild simbuild siminst simplay} {
        ::twt::simulation::assert_page_accessible /simulation/$module
    }
    
    # Set the on_map_p attribute
    ::twt::simulation::create_edit_delete_property
}

ad_proc ::twt::simulation::test::permissions_template_author {} {

    set group_name "Template Authors"
    ::twt::log_section "Permission testing for $group_name user"
    ::twt::user::login [::twt::simulation::permission_user_email $group_name]

    # read/create templates, only own templates
    # cannot edit other people's templates
    
    # TODO: can do anything in siminst

    # Access each module
    foreach module {citybuild simbuild siminst simplay} {
        ::twt::simulation::assert_page_accessible /simulation/$module
    }

    # TODO: cannot see case logs
}

ad_proc ::twt::simulation::test::permissions_case_author {} {

    set group_name "Case Authors"
    ::twt::log_section "Permission testing for $group_name user"
    ::twt::user::login [::twt::simulation::permission_user_email $group_name]

    # cannot access modules: simbuild
    foreach module {simbuild} {
        ::twt::simulation::assert_page_not_accessible /simulation/$module
    }
    foreach module {citybuild siminst simplay} {
        ::twt::simulation::assert_page_accessible /simulation/$module
    }

    # TODO: can see case logs

    # cannot set on_map_p attribute
}

ad_proc ::twt::simulation::test::permissions_service_admin {} {

    set group_name "Service Admins"
    ::twt::log_section "Permission testing for $group_name user"
    ::twt::user::login [::twt::simulation::permission_user_email $group_name]

    # can add users

    # TODO: can make users eligible for enrollment
}

ad_proc ::twt::simulation::test::permissions_actor {} {

    set group_name "Actors"
    ::twt::log_section "Permission testing for $group_name user"
    ::twt::user::login [::twt::simulation::permission_user_email $group_name]

    # TODO: participate in the simulation in simplay

    foreach module {citybuild simbuild siminst} {
        ::twt::simulation::assert_page_not_accessible /simulation/$module
    }
}

##############################
#
# ::twt::simulation::play
#
##############################

ad_proc ::twt::simulation::play::tilburg_template_user_1 {} {
    set user_name "Demo User 1"
    ::twt::log_section "Login with $user_name and play tilburg simulation"

    ::twt::user::login [::twt::simulation::email_from_user_name $user_name]

    do_request /simulation/simplay
    link follow ~u "case.+case"

    # Execute the ask client task
    link follow ~u task-detail
    form find ~n action
    field fill "ask client subject" ~n subject
    field fill "ask client body" ~n body
    form submit

    # Execute the finalizing task
    link follow ~c "Write legal advice"
    form find ~n action
    field fill "legal advice subject" ~n subject
    field fill "legal advice body" ~n body
    form submit

    # Legal advice was the last task so there shouldn't be any left
    if { [regexp {task-detail\?} [response body]] } {
        error "Completed last task ask legal advice but there are still tasks remaining"
    }

    # Visit case index page again
    do_request /simulation/simplay
    link follow ~u "case.+case"    

    # Send a message
    link follow ~u "message\\?"
    form find ~n message
    field find ~n recipient_role_id ~t checkbox
    field check
    field fill "message subject" ~n subject
    field fill "message body" ~n body
    form submit

    # Upload a document
    link follow ~u document-upload
    form find ~n document
    field find ~n document_file
    field fill [::twt::config::serverroot]/packages/simulation/test/new-jersey-lawyer-logo.gif    
    field fill "New Jersey Lawyers Logo" ~n title
    form submit
}

##############################
#
# ::twt::simulation helper procs
#
##############################

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
    {-characters_list:required}
} {
    array set characters $characters_list

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
    {-tasks_list:required}
} {
    array set tasks $tasks_list

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

ad_proc ::twt::simulation::create_edit_delete_property {} {

    set object_title "Test property"
    ::twt::simulation::add_object -type sim_prop -title $object_title

    # can edit on_map_p attribute of object
    do_request /simulation/citybuild
    link follow ~c $object_title
    link follow ~u object-edit
    regexp {item%5fid=([0-9]+)} [response url] match item_id
    form find ~n object
    field find ~n attr__sim_prop__on_map_p
    field select2 ~v t
    form submit
    if { [regexp "Permission Denied" [response body]] } {
        error "Got permission denied when editing on_map_p of an object"
    }

    # can delete object    
    do_request "/simulation/citybuild/object-delete?confirm_p=1&item_id=$item_id"
    if { [regexp "Permission Denied" [response body]] } {
        error "Got permission denied when deleting an object"
    }
}
