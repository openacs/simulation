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
        down {
            sub_class narrow
            display_template {
                <if @states.down_url@ not nil>
                  <a href="@states.down_url@" class="button" style="padding-top: 6px; padding-bottom: -2px; padding-left: 1px; padding-right: 1px;"><img src="/resources/acs-subsite/arrow-down.gif" border="0"></a>
                </if>
            }
        }
        up {
            sub_class narrow
            display_template {
                <if @states.up_url@ not nil>
                <a href="@states.up_url@" class="button" style="padding-top: 6px; padding-bottom: -2px; padding-left: 1px; padding-right: 1px;"><img src="/resources/acs-subsite/arrow-up.gif" border="0"></a>
                </if>
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
set counter 0
db_multirow -extend { edit_url char_url delete_url up_url down_url } states select_states "
    select ws.state_id,
           ws.pretty_name,
           ws.sort_order
      from workflow_fsm_states ws
     where ws.workflow_id = :workflow_id
     order by ws.sort_order
" {
    incr counter
    set edit_url [export_vars -base "[ad_conn package_url]simbuild/state-edit" { state_id }]
    set delete_url [export_vars -base "[ad_conn package_url]simbuild/state-delete" { state_id { return_url [ad_return_url] } }]
    if { $counter > 1 } {
        set up_url [export_vars -base "[ad_conn package_url]simbuild/template-object-reorder" { { type state } state_id { direction up } { return_url [ad_return_url] } }]
    }
    set down_url [export_vars -base "[ad_conn package_url]simbuild/template-object-reorder" { { type state } state_id { direction down } { return_url [ad_return_url] } }]
}

# Get rid of the last down_url
set states:${counter}(down_url) {}
