ad_page_contract {
    Page confirming that the mapping - step one of the instantiation
    process - has been completed. Ther user can proceed with
    casting or finish at this point.

    @author Peter Marklund
} {
    workflow_id:integer
}

set page_title "Mapping Completed"
set context [list [list "." "SimInst"] $page_title]
