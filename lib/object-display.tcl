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
    array set item [bcms::item::get_item_by_url -root_id $root_id -url $extra_url -revision live]
} else {
    array set item [bcms::revision::get_revision -revision_id $revision_id]
}
item::get_content \
    -revision_id $item(revision_id) \
    -array content

set content_html [ad_html_text_convert -from $content(mime_type) -to "text/html" -- $content(text)] 


######
#
# Temporary hack to dipslay attributes
#
#####

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

set page_title $item(title)
set context [list [list ../object-list "Objects"] $page_title]

foreach name [lsort [array names content]] {
    multirow append attributes $name $content($name)
}


if { [permission::write_permission_p -object_id $item(item_id)] } {
    set edit_url [export_vars -base [ad_conn package_url]object-edit { { item_id $item(item_id) } }]
    set delete_url [export_vars -base [ad_conn package_url]object-delete { { item_id $item(item_id) } }]
}


#####
#
# Render using template
#
#####

# Dropped
return

item::get_content \
    -revision_id [item::get_live_revision [item::get_template_id $item(item_id)]] \
    -array template

# Make content available to rendered page
foreach __elm [array names content] { 
    set $__elm $content($__elm)
}


publish::push_id $item_id $revision_id
set code [template::adp_compile -string $template(text)]
set rendered_page [template::adp_eval code]
publish::pop_id


