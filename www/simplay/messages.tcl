ad_page_contract {
    Simplay index page.
}

set page_title "Messages"
set user_id [ad_conn user_id]
set context [list [list "." "SimPlay"] [list $page_title] ]
set package_id [ad_conn package_id]
