ad_page_contract {
    Show all tasks for a user_id.
}

set page_title "Tasks"
set user_id [ad_conn user_id]
set context [list [list "." "SimPlay"] [list $page_title] ]
set package_id [ad_conn package_id]
