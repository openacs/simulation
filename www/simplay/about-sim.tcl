ad_page_contract {
    Information about a sim.
} {
    case_id:integer
}

set workflow_id [simulation::case::get_element -case_id $case_id -element workflow_id]

set description [simulation::template::get_element -workflow_id $workflow_id -element description]
set description_mime_type [simulation::template::get_element -workflow_id $workflow_id -element description_mime_type]
set description [ad_html_text_convert -from $description_mime_type -maxlen 200 -- $description]

set simulation_name [simulation::template::get_element -workflow_id $workflow_id -element pretty_name]

set title "About $simulation_name"
set context [list [list . "SimPlay"] [list [export_vars -base case { case_id }] "$simulation_name"] $title]
