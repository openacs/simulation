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
    set email_account [string map {" " _} "$first_names $last_name"]
    field fill "${email_account}@test.test"
    field find ~n first_names
    field fill $first_names
    field find ~n last_name
    field fill $last_name
    field find ~n password
    field fill "1"
    field find ~n password_confirm
    field fill "1"

    form submit
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
