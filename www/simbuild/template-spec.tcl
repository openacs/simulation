ad_page_contract {
    Generate and download a specification for a workflow.
    
    @author Lars Pind
    @creation-date 2003-12-10
} {
    workflow_id:integer
    {deep_p:boolean "f"}
}

set page_title "Template Specifiaction"
set context [list [list "." "SimBuild"] [list [export_vars -base template-edit { workflow_id }] "Template"] $page_title] 

set spec [simulation::template::generate_spec -workflow_id $workflow_id -deep=[template::util::is_true $deep_p]]

set spec [util::array_list_spec_pretty $spec]
