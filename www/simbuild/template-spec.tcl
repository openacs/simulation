ad_page_contract {
    Generate and download a specification for a workflow.
    
    @author Lars Pind
    @creation-date 2003-12-10
} {
    workflow_id:integer
}

set spec [simulation::template::generate_spec -workflow_id $workflow_id] 

ns_return 200 text/plain [util::array_list_spec_pretty $spec]
