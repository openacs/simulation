ad_page_contract {
    Delete a simulation template.

    @creation-date 2003-11-12
    @cvs-id $Id$
} {
    workflow_id
}

set template_name [workflow::get_element -workflow_id $workflow_id -element pretty_name]
set package_id [ad_conn package_id]

set page_title "Deleting template \"$template_name\""
set template_list_url sim-template-list
set context [list [list $template_list_url "Templates"] $page_title]

#simulation::template::delete -workflow_id $workflow_id
