ad_page_contract {
    Displays a Simulation Object
    
    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
} {
    revision_id:optional,naturalnum
    {printer_friendly_p:optional 0}
}

set root_id [bcms::folder::get_id_by_package_id -parent_id 0]

# This little exercise removes the object/ part from the extra_url
set extra_url [eval file join [lrange [file split [ad_conn extra_url]] 1 end]]

if { [empty_string_p $extra_url] } {
    set extra_url "index"
}

# get the item by url if now revision id is given
if { ![info exists revision_id] } {
    array set current_item [bcms::item::get_item_by_url -root_id $root_id -url $extra_url -revision live]
} else {
    array set current_item [bcms::revision::get_revision -revision_id $revision_id]
}

# TODO: Render using template
#set rendered [publish::merge_with_template $current_item(item_id)]

template::list::create \
    -name attributes \
    -multirow attributes \
    -elements {
        attribute {
            label "Attribute"
        }
        value {
            label "Value"
        }
    }

multirow create attributes attribute value 

set page_title $current_item(title)
set context [list [list ../object-list "Objects"] $page_title]

foreach name [array names current_item] {
    multirow append attributes $name $current_item($name)
}

