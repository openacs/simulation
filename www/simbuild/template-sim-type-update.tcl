ad_page_contract {
    Mark a template ready for use
} {
    workflow_id:integer
    {sim_type "ready_template"}
    {return_url {[export_vars -base "template-edit" { workflow_id }]}}
} -validate {
    inits_exist -requires {workflow_id:integer} {
	if { [string match $sim_type "ready_template"] } {
	    if { ![simulation::template::check_init_p -workflow_id $workflow_id] } {
		ad_complain "<p>Either the simulation template or one of its subworkflows
                             seems to be missing an initial action. Please correct this
                             before you try to mark this template ready for use.</p>
                             <p>Note that every subworkflow and parallel task must
                             also have its own initial action.</p>"
	    }
	}
    }
}

permission::require_write_permission -object_id $workflow_id

set row(sim_type) $sim_type

simulation::template::edit \
    -workflow_id $workflow_id \
    -array row

ad_returnredirect $return_url