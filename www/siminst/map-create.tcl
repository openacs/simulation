ad_page_contract {
    A page that creates a mapped template by cloning a ready template.
    This is the first step in the mapping process.

    @author Peter Marklund
} {
    workflow_id:integer
}

set page_title "Create mapped template"
set context [list [list "." "SimInst"] $page_title]

set old_name [workflow::get_element -workflow_id $workflow_id -element pretty_name]
set name_default "$old_name Mapped"

ad_form \
    -name template \
    -export { workflow_id } \
    -form {
        {pretty_name:text
            {label "Template name"}
            {value $name_default}
            {html {size 50}}
        }
    } -on_submit {
        # Create a new template that is clone of the existing one
        set workflow_id [simulation::template::clone \
                            -workflow_id $workflow_id \
                            -pretty_name $pretty_name]

        # Proceed to the task page
        ad_returnredirect [export_vars -base map-tasks {workflow_id}]
        ad_script_abort

    }
