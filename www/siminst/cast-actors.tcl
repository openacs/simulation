ad_page_contract {
    The page where actors are chosen for the different
    roles of a simulation. Part of the casting step
    in the instantiation process.

    @author Peter Marklund
} {
    workflow_id:integer
}

set page_title "Choose actors"
set context [list [list "." "SimInst"] $page_title]
