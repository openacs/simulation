ad_page_contract {
    This page shows the full task, message, and document history of
    a simulation case.

    @author Peter Marklund
} {
    case_id:integer
}

simulation::case::get -case_id $case_id -array case

set page_title "Full History for $case(label)"
set context [list [list . "SimPlay"] $page_title]

