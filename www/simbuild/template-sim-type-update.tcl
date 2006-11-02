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
		ad_complain "<h2>The simulation cannot yet be marked as ready</h2>
		<p>There are a few possible reasons for this:</p>
		<ul>
		<li>Either the simulation template or one of its subworkflows
                             is missing an initial action. Please correct this
                             before you try to mark this template ready for use.</p>
                             <p>Note that every subworkflow and parallel task must
                             also have its own initial action.</li>
    <li>All roles don't have an associated character. Correct this by assigning a character for each role you create for the template.</li>
    </ul>"
	    }
	}
    }
}

permission::require_write_permission -object_id $workflow_id

set row(sim_type) $sim_type

simulation::template::edit \
    -workflow_id $workflow_id \
    -array row

set message [ad_decode $sim_type "ready_template" [_ simulation.template_marked_as_ready] ""]

ad_returnredirect -message $message $return_url