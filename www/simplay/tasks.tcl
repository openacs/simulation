ad_page_contract {
    List of tasks for a case
} {
    case_id:integer
}

set title "Tasks"
set context [list [list . "SimPlay"] [list [export_vars -base case { case_id }] "Case"] $title]

set user_id [ad_conn user_id]
