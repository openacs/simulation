ad_page_contract {
    This page shows the full task, message, and document history of
    a simulation case.

    @author Peter Marklund
} {
    case_id:integer
}

simulation::case::get -case_id $case_id -array case

set page_title [_ simulation.lt_Full_History_for_case]
set context [list [list . [_ simulation.SimPlay]] $page_title]

