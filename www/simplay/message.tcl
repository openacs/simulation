ad_page_contract {
    Create or edit a message.
}

# TODO: task recipient_id as an optional input parameter

set page_title "Message"
set context [list [list "." "SimPlay"] [list $page_title] ]
set package_id [ad_conn package_id]