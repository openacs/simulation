ad_page_contract {
    Displays a Simulation Object
    
    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
} {
    revision_id:optional,naturalnum
    {printer_friendly_p:optional 0}
    case_id:optional
    role_id:optional
    recipient_role_id:optional
}

set package_id [ad_conn package_id]
set package_url [ad_conn package_url]

set root_id [bcms::folder::get_id_by_package_id -parent_id 0]

set base_url [ad_conn urlv]

set simplay 1
if { [lsearch -exact $base_url "simplay"] == -1 } { 
    set simplay 0
}

# This little exercise removes the object/ part from the extra_url
# Let's just use path_info
# set extra_url [eval file join [lrange [file split [ad_conn extra_url]] 1 end]]
set extra_url [ad_conn path_info]

if { [empty_string_p $extra_url] } {
    set extra_url "index"
}

# get the item by url if no revision id is given
if { ![info exists revision_id] } {
    array set item [bcms::item::get_item_by_url -root_id $root_id -url $extra_url -revision live]
} else {
    array set item [bcms::revision::get_revision -revision_id $revision_id]
}

item::get_content \
    -revision_id $item(revision_id) \
    -array content

#file delete /web/lars/www/picture.jpg

#error [publish::handle::image 580 -html {} -revision_id 581]

#error [publish::render_subitem 586 relation image 1 f {refresh 1}]

if { [info exists content(text)] } {
    switch $content(mime_type) {
        text/enhanced - text/plain - text/fixed-width - text/html {
            publish::push_id $item(item_id)
            set content_html [ad_html_text_convert -from $content(mime_type) -to "text/html" -- $content(text)]
            set code [template::adp_compile -string $content_html]
            set content_html [template::adp_eval code]
            publish::pop_id
        }
        default {
            set content_html [ad_quotehtml $content(text)]
        }
    }
} else {
    set content(text) ""
    set content(html) ""
}


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
set context [list $page_title]

set recipient_p 0

# We are in simplay/object, so we need stuff for the control and context bars
if { $simplay } {
    # We do have case_id, it's required by simplay/object/index.vuh
    simulation::case::get -case_id $case_id -array case
    set section_uri [apm_package_url_from_id $package_id]simplay/
    set case_url [export_vars -base ${section_uri}case { case_id role_id }]

    if { [exists_and_not_null recipient_role_id] } {
	set role_name [simulation::role::get_element -role_id $recipient_role_id -element pretty_name]
	set recipient_p 1
	set message_url [export_vars -base ../message { role_id case_id recipient_role_id }]
	set page_title "${item(title)} (${role_name})"
    }

    set context [list [list $section_uri [_ simulation.SimPlay]] [list $case_url $case(label)] $page_title]
    
}



foreach name [lsort [array names content]] {
    multirow append attributes $name $content($name)
}


if { [permission::write_permission_p -object_id $item(item_id) -party_id [ad_conn user_id]] } {
    set edit_url [export_vars -base [apm_package_url_from_id $package_id]citybuild/object-edit { { item_id $item(item_id) } }]
    set delete_url [export_vars -base [apm_package_url_from_id $package_id]/citybuild/object-delete { { item_id $item(item_id) } }]
}

#####
#
# Serve stylesheet
#
#####
set related_stylesheets [bcms::item::list_related_items \
                             -item_id $item(item_id) \
                             -relation_tag stylesheet \
                             -return_list]
if { [llength $related_stylesheets] > 0 } {
    set first_stylesheet [lindex $related_stylesheets 0]
    set stylesheet_id [ns_set get $first_stylesheet item_id]

    array set item [bcms::item::get_item -item_id $stylesheet_id]
    set stylesheet_url [simulation::object::content_url -name $item(name)]
} else {
    set stylesheet_url {}
}
