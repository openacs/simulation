simulation::include_contract {
    A list of all states associated with the Simulation Template

    @author Peter Marklund
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    workflow_id {}
}

set package_id [ad_conn package_id]

#-------------------------------------------------------------
# states list 
#-------------------------------------------------------------

set actions [list "Add a State" [export_vars -base state-edit { workflow_id}] {}]

template::list::create \
    -name states \
    -multirow states \
    -no_data "No states in this Simulation Template" \
    -actions $actions \
    -elements {
        edit {
            sub_class narrow
            link_url_col edit_url
            display_template {
                <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border="0" alt="Edit">
            }
        }
        name { 
            label "Name"
            display_col pretty_name
            link_url_col edit_url
        }
        delete {
            sub_class narrow
            display_template {
                <a href="@states.delete_url@" onclick="return confirm('Are you sure you want to delete state @states.pretty_name@?');">
                  <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Edit">
                </a>
            }
        }
    }
#-------------------------------------------------------------
# states db_multirow
#-------------------------------------------------------------
set return_url "[ad_conn url]?[ad_conn query]"
db_multirow -extend { edit_url char_url delete_url } states select_states "
    select ws.state_id,
           ws.pretty_name
      from workflow_fsm_states ws
     where ws.workflow_id = :workflow_id
     order by ws.sort_order
" {
    set edit_url [export_vars -base "[ad_conn package_url]simbuild/state-edit" { state_id }]
    set delete_url [export_vars -base "[ad_conn package_url]simbuild/state-delete" { state_id return_url }]
}
