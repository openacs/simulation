ad_page_contract {
    List of messages for a case
} {
    case_id:integer
}

set title "Messages"
set context [list [list . "SimPlay"] [list [export_vars -base case { case_id }] "Case"] $title]

set user_id [ad_conn user_id]
