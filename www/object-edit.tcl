ad_page_contract {
    Add/edit object.

    @creation-date 2003-10-13
    @cvs-id $Id$
} {
    item_id:integer,optional
    parent_id:integer,optional
    content_type:optional
} -validate {
    not_item_id {
        if { ![exists_and_not_null item_id] } {
            if { ![exists_and_not_null parent_id] } {
                ad_complain "parent_id is required"
            }
            if { ![exists_and_not_null content_type] } {
                ad_complain "content_type is required"
            }
        }
    }
}

ad_form -name object -cancel_url object-list -form {
    {item_id:key}
    {content_type:text(hidden)}
    {parent_id:integer(hidden),optional}
    {title:text
        {label "Title"}
        {html {size 50}}
    }
    {name:text,optional
        {label "URL name"}
        {html {size 50}}
        {help_text {[ad_decode [ad_form_new_p -key item_id] 1 "This will become part of the URL for the object." ""]}}
        {mode {[ad_decode [ad_form_new_p -key item_id] 1 "edit" "display"]}}
    }
    {description:text(textarea),optional
        {label "Description"}
        {html {cols 60 rows 8}}
    }
}

if { ![ad_form_new_p -key item_id] } {
    # Get data for existing object
    array set item_info [bcms::item::get_item -item_id $item_id -revision live]
    item::get_revision_content $item_info(revision_id)
    set content_type $item_info(content_type)
    set page_title "Edit Object"
} else {
    set object_type_pretty [db_string pretty { select pretty_name from acs_object_types where object_type = :content_type }]
    set page_title "Create $object_type_pretty"
}
set context [list [list "object-list" "Objects"] $page_title]


#####
#
# Content edit/upload method
#
#####

array set content_method {
    sim_character richtext
    sim_home richtext
    sim_prop richtext
}

if { [info exists content_method($content_type)] } {

    switch $content_method($content_type) {
        richtext {
            ad_form -extend -name object -form {
                {content_elm:richtext(richtext),optional
                    {label "Content"}
                    {html {cols 60 rows 8}}
                }
            }
        }
        upload {
            
        }
    }

}


#####
#
# Dynamic attributes for the content type
#
#####

# LARS: I'm doing this as a proof-of-concept type thing. If it works well enough for us, 
# we'll want to generalize and move into acs-content-repository

array set form_datatype {
    string text
    boolean text
    number text
    integer integer
    money text
    date text
    timestamp text
    time_of_day text
    enumeration text
    url text
    email text
    text text
    keyword integer
}

array set form_widget {
    string text
    boolean text
    number text
    integer text
    money text
    date text
    timestamp text
    time_of_day text
    enumeration text
    url text
    email text
    text textarea
    keyword integer
}

array set form_extra {
    string {
        {html {size 50}}
    }
    boolean {}
    number {}
    integer {}
    money {}
    date {}
    timestamp {}
    time_of_day {}
    enumeration {}
    url {
        {html {size 50}}
    }
    email {
        {html {size 50}}
    }
    text {
        {html {cols 60 rows 8}}
    }
    keyword {}
}

set attr_names [list]

db_foreach select_attributes {
    select attribute_name, pretty_name, datatype, default_value, min_n_values
    from   acs_attributes
    where  object_type = :content_type
    and    storage = 'type_specific'
    and    static_p = 'f'
    order  by sort_order
} {
    lappend attr_names $attribute_name

    set elm_decl "attr__${content_type}__${attribute_name}:$form_datatype($datatype)($form_widget($datatype))"

    set optional_p [expr ![empty_string_p $default_value] || $min_n_values == 0]
    if { $optional_p } {
        append elm_decl ",optional"
    }

    ad_form -extend -name object -form \
        [list [concat [list $elm_decl [list label \$pretty_name]] $form_extra($datatype)]]
}


ad_form -extend -name object -new_request {
    # Set element values from local vars
} -on_submit {

    set attributes [list]
    foreach attribute_name $attr_names {
        lappend attributes $attribute_name [set attr__${content_type}__${attribute_name}]
    }

} -new_data {
    
    set existing_items [db_list select_items { select name from cr_items where parent_id = :parent_id }]

    if { [empty_string_p $name] } {
        set name [util_text_to_url -existing_urls $existing_items -text $title]
    } else {
        if { [lsearch $existing_items $name] != -1 } {
            form set_error object name "This name is already in use"
            break
        }
    }

    set item_id [bcms::item::create_item \
                     -item_name $name \
                     -parent_id $parent_id \
                     -content_type $content_type]
    
    set content_text [template::util::richtext::get_property contents $content_elm]
    set mime_type [template::util::richtext::get_property format $content_elm]

    set revision_id [bcms::revision::add_revision \
                         -item_id $item_id \
                         -title $title \
                         -content_type $content_type \
                         -mime_type $mime_type \
                         -content $content_text \
                         -description $description \
                         -additional_properties $attributes]

    bcms::revision::set_revision_status \
        -revision_id $revision_id \
        -status "live"

} -edit_request {
    
    foreach elm { title name description } {
        set $elm $content($elm)
    }
    
    foreach attribute_name $attr_names {
        set attr__${content_type}__${attribute_name} $content($attribute_name)
    }
    
    set content_elm [template::util::richtext::create $content(text) $content(mime_type)]
} -edit_data {

    set content_text [template::util::richtext::get_property contents $content_elm]
    set mime_type [template::util::richtext::get_property format $content_elm]

    set revision_id [bcms::revision::add_revision \
                         -item_id $item_id \
                         -title $title \
                         -content_type $content_type \
                         -mime_type $mime_type \
                         -content $content_text \
                         -description $description \
                         -additional_properties $attributes]

    bcms::revision::set_revision_status \
        -revision_id $revision_id \
        -status "live"

    
    
} -after_submit {
    ad_returnredirect object-list
    ad_script_abort
}
