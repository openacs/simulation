ad_page_contract {
    Load a simulation from a spec

} {
    cancel_url:optional
}

if { ![exists_and_not_null cancel_url] } {
    set cancel_url [get_referrer]
}

permission::require_permission -object_id [ad_conn package_id] -privilege sim_template_create

set page_title "Load Template"

set context [list [list "." "SimBuild"] $page_title]

ad_form -name load \
    -cancel_url $cancel_url \
    -edit_buttons [list [list "Load" ok]] -form {
	{pretty_name:text
	    {label "Name"}
	    {html {size 50}}
	}
	{spec:text(textarea),nospell
	    {label "Spec"}
	    {help_text {Copy and paste the specification here.  A specification is a plain-text file which can be generated when editing a template.}}
	    {html {cols 80 rows 10}}
	}
	{cancel_url:text(hidden) }
} -on_request {

} -on_submit {
    with_catch errmsg {
        set row(pretty_name) $pretty_name
        set row(short_name) {}
        simulation::template::new_from_spec \
            -package_key "simulation" \
            -object_id [ad_conn package_id] \
            -spec $spec \
            -array row
    } {
        global errorInfo
        ns_log Error "Error loading workflow: $errorInfo"
        form set_error load spec $errmsg
        break
    }

    ad_returnredirect .
    ad_script_abort
}

