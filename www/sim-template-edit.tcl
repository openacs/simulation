ad_page_contract {
    Add/edit template.

    @creation-date 2003-10-13
    @cvs-id $Id$
} {
    workflow_id:optional
}

set package_key [ad_conn package_key]
set package_id [ad_conn package_id]

######################################################################
#
# sim_template
#
# a form showing fields for a sim template
# includes add, edit, and display modes and handles form submission
#
# TODO: display mode doesn't exist yet - all display is through edit mode
#
######################################################################

#---------------------------------------------------------------------
# sim_template form
#---------------------------------------------------------------------

ad_form -name sim_template -cancel_url sim-template-list -form {
    {workflow_id:key}
    {name:text,optional
        {label "Template Name"}
        {html {size 40}}
    }
} -edit_request {
    workflow::get -workflow_id $workflow_id -array sim_template_array
    set name $sim_template_array(pretty_name)
    set page_title "Edit template $name"
    set context [list [list "sim-template-list" "Templates"] $page_title]
} -new_request {
    set page_title "Create template"
    set context [list [list "sim-template-list" "Templates"] $page_title]
} -new_data {
    set workflow_id [workflow::new \
                         -short_name $name \
                         -pretty_name $name \
                     -package_key $package_key]
    # create a dummy action with initial action setting because
    # workflow::get doesn't work on bare workflows
    workflow::action::fsm::new -initial_action_p t -workflow_id $workflow_id \
                         -short_name "dummy action" \
                         -pretty_name "dummy action"
} -after_submit {
    ad_returnredirect sim-template-edit?workflow_id=$workflow_id
    ad_script_abort
}

#---------------------------------------------------------------------
# Determine if we are in edit mode or display mode
#---------------------------------------------------------------------
# this is prototype code to correct for get_action's apparent
# unreliability

set mode [template::form::get_action sim_template]
if { ![exists_and_not_null workflow_id]} {
    set mode "add"
} else {
    # for now, use edit mode in place of display mode
    #    set mode "display"
    set mode "edit"
}

######################################################################
#
# sim_template
#
# a form showing fields for a sim template, handling view mode and 
# edit mode, and handling form submission 
#
######################################################################

switch $mode {
    add {
        set page_title "New Simulation Template"
    }
    edit {
        set page_title "Editing $name"

        #-------------------------------------------------------------
        # in display mode, show lists of subordinate things
        #-------------------------------------------------------------
        
        ##############################################################
        #
        # sim_objects
        #
        # A list of all objects associated with the Simulation Template
        #
        ##############################################################

        # maybe replace this chunk of copied text with an includable template
        # which passes in a filter for the workflow_id?


        #-------------------------------------------------------------
        # sim_objects list 
        #-------------------------------------------------------------
        
        template::list::create \
            -name sim_objects \
            -multirow sim_objects \
            -elements {
                edit {
                    sub_class narrow
                    link_url_col edit_url
                    display_template {
                        <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border="0" alt="Edit">
                    }
                }
                object_type_pretty {
                    label "Type"
                    orderby upper(ot.pretty_name)
                }
                title { 
                    label "Title"
                    orderby r.title
                    link_url_col view_url
                }
                description {
                    label "Description"
                    orderby r.description
                }
            }
        
        db_multirow -extend { edit_url view_url delete_url } sim_objects select_sim_objects "
    select i.item_id,
           i.name,
           r.title,
           r.description,
           i.content_type,
           ot.pretty_name as object_type_pretty
    from   cr_folders f,
           cr_items i,
           cr_revisions r,
           acs_object_types ot,
           sim_workflow_object_map swom
    where  f.package_id = :package_id
    and    i.parent_id = f.folder_id
    and    r.revision_id = i.live_revision
    and    ot.object_type = i.content_type
    and    swom.workflow_id = :workflow_id
    and    swom.object_id = i.item_id

    [template::list::orderby_clause -orderby -name "sim_objects"]
" {
    set description [string_truncate -len 200 $description]
    set edit_url [export_vars -base "object-edit" { item_id }]
    set view_url [export_vars -base "object/$name"]
    set delete_url [export_vars -base "object-delete" { item_id }]
}

        set sim_types { sim_character sim_prop sim_home }
        
        db_multirow -extend { create_url label } object_types select_object_types "
    select ot.object_type as content_type,
           ot.pretty_name
    from   acs_object_types ot
    where  ot.object_type in ('[join $sim_types "','"]')
" {
    set create_url [export_vars -base object-edit { content_type parent_id }]
    set label "Create new $pretty_name"
}

        ##############################################################
        #
        # roles
        #
        # A list of all roles associated with the Simulation Template
        #
        ##############################################################

        # maybe replace this chunk of copied text with an includable template
        # which passes in a filter for the workflow_id?


        #-------------------------------------------------------------
        # roles list 
        #-------------------------------------------------------------
        
        template::list::create \
            -name roles \
            -multirow roles \
            -elements {
                edit {
                    sub_class narrow
                    link_url_col edit_url
                    display_template {
                        <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" border="0" alt="Edit">
                    }
                }
                title { 
                    label "Name"
                }
                character {
                    label "Character"
                    link_url_col char_url
                }
                delete {
                    sub_class narrow
                    link_url_col delete_url
                    display_template {
                        <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" border="0" alt="Edit">
                    }
                }
            }

# TODO: fix this so it returns rows when it should        
        db_multirow -extend { edit_url char_url delete_url } roles select_roles "
    select wr.role_id,
           wr.pretty_name as name,
           wr.sort_order,
           cr.title as character,
           i.name as char_name
      from workflow_roles wr,
           sim_roles sr,
           cr_revisions cr,
           cr_items i
     where wr.workflow_id = :workflow_id
       and sr.role_id = wr.role_id
       and cr.item_id = sr.character_id
       and i.item_id = sr.character_id
    [template::list::orderby_clause -orderby -name "roles"]
" {
    set edit_url [export_vars -base "role-edit" { role_id }]
    set char_url [export_vars -base "object/$char_name"]
    set delete_url [export_vars -base "role-delete" { role_id }]
}
    }
}

set context [list [list "sim-template-list" "Sim Templates"] $page_title] 


# maybe replace this chunk of copied text with an includable template
# which passes in a filter for the workflow_id?

