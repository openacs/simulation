ad_page_contract {
    Delete an object.
} {
    {confirm_p:boolean "f"}
    item_id:integer
    {return_url "."}
}

if { [template::util::is_true $confirm_p] } {
    permission::require_write_permission -object_id $item_id    
    bcms::item::delete_item -item_id $item_id
    ad_returnredirect $return_url
}

array set item [bcms::item::get_item -item_id $item_id -revision live]
set page_title "Delete object \"$item(title)\""
set context [list [list "." "CityBuild"] $page_title]

set delete_url [export_vars -base [ad_conn url] { item_id return_url { confirm_p 1 } }]
set cancel_url $return_url
