ad_page_contract {
    Delete an object.
} {
    {confirm_p:boolean "f"}
    item_id:integer
    {return_url "object-list"}
}

permission::require_permission -object_id $item_id -privilege write

if { [template::util::is_true $confirm_p] } {
    bcms::item::delete_item -item_id $item_id
    ad_returnredirect $return_url
}

set page_title "Delete Object"
set context [list [list "object-list" "Objects"] $page_title]

set delete_url [export_vars -base [ad_conn url] { item_id return_url { confirm_p 1 } }]
set cancel_url $return_url
