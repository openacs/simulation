ad_library {
    API for Simulation roles.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::role {}

ad_proc -public simulation::role::new {
    {-template_id:required}
    {-short_name {}}
    {-pretty_name:required}
} {
    Create a new simulation role for a given simulation template. 
    Will map the character to the template if this
    is not already done.

    @author Peter Marklund
} {
    db_transaction {
        set role_id [workflow::role::new \
                         -workflow_id $template_id \
                         -short_name $short_name \
                         -pretty_name $pretty_name]

        db_dml insert_sim_role {
            insert into sim_roles (role_id) values (:role_id)
        }
    }    
}

ad_proc -public simulation::role::delete {
    {-role_id:required}
} {
    db_transaction {
        workflow::role::delete -role_id $role_id

        db_dml delete_sim_role {
            delete from sim_roles where role_id = :role_id
        }
    }
}

ad_proc -public simulation::role::edit {
    {-role_id:required}
    {-character_id:required}
} {
    Edit a simulation role.
} {
    db_dml edit_sim_role {
        update sim_roles
        set character_id = :character_id
        where role_id = :role_id
    }
}
