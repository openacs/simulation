ad_library {
    Simulation Case Library.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::case {}

ad_proc -public simulation::case::get {
    {-case_id:required}
    {-array:required}
} {
    Return information about a simulation case.  This is a wrapper around 
    workflow::case::get, supplementing it with the columns from sim_cases.

    @param case_id ID of simulation case.
    @param array name of array in which the info will be returned
                 Array will contain keys from the tables workflow_cases and sim_cases.
} {
    upvar $array row

    workflow::case::get -array row -case_id $case_id

    db_1row select_case {
        select sc.label,
               sc.package_id
        from sim_cases sc,
             workflow_cases wc
        where wc.case_id = :case_id
          and wc.object_id = sc.sim_case_id 
    } -column_array local_row

    array set row [array get local_row]
}

ad_proc -public simulation::case::get_element {
    {-case_id:required}
    {-element:required}
} {
    Return a single element from the information about a case.

    @param case_id     The ID of the case
    @param element     The element you want

    @return            The element you asked for

    @author Peter Marklund
} {
    get -case_id $case_id -array row
    return $row($element)
}

ad_proc -public simulation::case::new {
    {-workflow_id:required}
    {-label ""}
    {-creation_user ""}
    {-creation_ip ""}
    {-object_type "sim_case"}
} {
    Create a new simuation case for a given simulation (workflow).

    @return sim_case_id
} {
    set package_id [ad_conn package_id]

    set extra_vars [ns_set create]
    oacs_util::vars_to_ns_set \
        -ns_set $extra_vars \
        -var_list { package_id label }

    set sim_case_id [package_instantiate_object \
                         -creation_user $creation_user \
                         -creation_ip $creation_ip \
                         -package_name "sim_case" \
                         -extra_vars $extra_vars \
                         $object_type]
                     
    set case_id [workflow::case::new \
                     -workflow_id $workflow_id \
                     -object_id $sim_case_id \
                     -user_id $creation_user]

    return $sim_case_id
}


ad_proc -public simulation::case::attachment_options {
    {-case_id:required}
    {-role_id:required}
} {
    Get labels and ids of attachments associated with the given case and role.

    @return A list of label-id pairs suitable for the options attribute of a form builder select widget.

    @author Peter Marklund
} {
    return [db_list_of_lists attachment_for_role {
        select cr.title as document_title,
               scrom.object_id as document_id
        from sim_case_role_object_map scrom,
             cr_items ci,
             cr_revisions cr
        where scrom.case_id = :case_id
          and scrom.role_id = :role_id
          and scrom.object_id = ci.item_id
          and ci.live_revision = cr.revision_id
        order by scrom.order_n
    }]
}
