ad_library {
    API for Simulation roles.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::role {}

ad_proc -public simulation::role::new {
    {-template_id:required}
    {-role_short_name:required}
    {-role_pretty_name:required}
} {
    Create a new simulation role for a given simulation template. 
    Will map the character to the template if this
    is not already done.

    @author Peter Marklund
} {
    db_transaction {
        # create the role
        set role_id [workflow::role::new \
                         -workflow_id $template_id \
                         -short_name $role_short_name \
                         -pretty_name $role_pretty_name]

    }    
}

ad_proc -public simulation::role::delete {
    {-role_id:required}
} {
    workflow::role::delete -role_id $role_id
}
