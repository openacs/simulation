ad_library {
    Simulation Case Library.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::case {}



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
