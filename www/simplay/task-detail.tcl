ad_page_contract {
    Show information for a single task.
}

set page_title "Task Information: taskname"
set context [list [list "." "SimPlay"] [list $page_title] ]
set package_id [ad_conn package_id]
