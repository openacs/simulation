ad_page_contract {
    Generate and download a specification for a workflow.
    
    @author Lars Pind
    @creation-date 2003-12-10
} {
    workflow_id:integer
}

set page_title "Export"

simulation::template::get -workflow_id $workflow_id -array sim_template_array

set context [list [list "." "SimBuild"] [list [export_vars -base template-edit { workflow_id }] "Editing $sim_template_array(pretty_name)"] $page_title] 

set spec [simulation::template::generate_spec -workflow_id $workflow_id]

set spec [util::array_list_spec_pretty $spec]
