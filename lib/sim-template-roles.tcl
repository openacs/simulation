simulation::include_contract {
    A list of all roles associated with the Simulation Template

    @author Joel Aufrecht
    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    workflow_id {}
    display_mode {
        allowed_values {edit display}
        default_value display
    }
    size {
        allowed_values {short long}
        default_value long
    }
}

set package_id [ad_conn package_id]

#-------------------------------------------------------------
# roles list 
#-------------------------------------------------------------

if { $display_mode == "edit"} {
    set actions [list "Add a Role" [export_vars -base role-edit {workflow_id} ]]
} else {
    set actions ""
}

template::list::create \
    -name roles \
    -multirow roles \
    -no_data "No roles in this Simulation Template" \
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
                <if @roles.down_url@ not nil>
                  <a href="@roles.down_url@" class="button" style="padding-top: 6px; padding-bottom: -2px; padding-left: 1px; padding-right: 1px;"><img src="/resources/acs-subsite/arrow-down.gif" border="0"></a>
                </if>
            }
        }
        up {
            sub_class narrow
            display_template {
                <if @roles.up_url@ not nil>
                <a href="@roles.up_url@" class="button" style="padding-top: 6px; padding-bottom: -2px; padding-left: 1px; padding-right: 1px;"><img src="/resources/acs-subsite/arrow-up.gif" border="0"></a>
                </if>
            }
        }
        name { 
            label "Name"
            display_col pretty_name
            link_url_col edit_url
        }
        character {
            label "Character"
            display_template {
              <if @roles.character_name@ eq "">
              <em>Not selected</em>
              </if>
              <else>
              @roles.character_name@
              </else>
            }
            link_url_col char_url
        }
        delete {
            sub_class narrow
            link_url_col delete_url
            link_html { onclick "return confirm('Are you sure you want to delete role @roles.pretty_name@?');" }
            display_template {
                <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Delete">
            }
        }
    }
#-------------------------------------------------------------
# roles db_multirow
#-------------------------------------------------------------
set counter 0
db_multirow -extend { edit_url char_url delete_url up_url down_url } roles select_roles "
    select wr.role_id,
           wr.pretty_name,
           wr.sort_order,
           sc.title as character_name,
           ci.name as character_url
      from workflow_roles wr,
           sim_roles sr
      left join cr_items ci on (sr.character_id = ci.item_id)
      left join sim_charactersx sc on (ci.item_id = sc.item_id 
                                and ci.live_revision = sc.object_id)
     where wr.workflow_id = :workflow_id
       and wr.role_id = sr.role_id
     order by wr.sort_order
" {
    incr counter
    set edit_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/role-edit" { role_id }]
    set char_url [ad_decode $character_name "" "" "[apm_package_url_from_id $package_id]object/${character_url}"]
    
    set delete_url [export_vars -base "[apm_package_url_from_id $package_id]simbuild/role-delete" { role_id { return_url [ad_return_url] } }]
    if { $counter > 1 } {
        set up_url [export_vars -base "[ad_conn package_url]simbuild/template-object-reorder" { { type role } role_id { direction up } { return_url [ad_return_url] } }]
    }
    set down_url [export_vars -base "[ad_conn package_url]simbuild/template-object-reorder" { { type role } role_id { direction down } { return_url [ad_return_url] } }]
}

# Get rid of the last down_url
set roles:${counter}(down_url) {}
