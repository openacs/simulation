ad_page_contract {
    Add/edit object.

    @creation-date 2003-10-13
    @cvs-id $Id$
} {
    object_id:integer,optional
    parent_id:integer
    content_type
}

set page_title "Create Object"
set context [list [list "object-list" "Objects"] $page_title]

ad_form -name object -form {
    {object_id:key}
    {content_type:text(hidden)}
    {parent_id:integer(hidden)}
    {title:text
        {label "Title"}
        {html {size 50}}
    }
    {name:text,optional
        {label "URL name"}
        {html {size 50}}
        {help_text "This will become part of the URL for the object."}
    }
    {description:text(textarea),optional
        {label "Description"}
        {html {cols 60 rows 8}}
    }
}

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

db_foreach select_attributes {
    select attribute_name, pretty_name, datatype, default_value, min_n_values
    from   acs_attributes
    where  object_type = :content_type
    and    storage = 'type_specific'
    and    static_p = 'f'
    order  by sort_order
} {
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

    set attributes [list]

    db_foreach select_attributes {
        select attribute_name, pretty_name, datatype, default_value, min_n_values
        from   acs_attributes
        where  object_type = :content_type
        and    storage = 'type_specific'
        and    static_p = 'f'
        order  by sort_order
    } {
        lappend attributes $attribute_name [set attr__${content_type}__${attribute_name}]
    }

    set item_id [bcms::item::create_item \
                     -item_name $name \
                     -parent_id $parent_id \
                     -content_type $content_type]
    
    set revision_id [bcms::revision::add_revision \
                         -item_id $item_id \
                         -title $title \
                         -content_type $content_type \
                         -mime_type "text/plain" \
                         -description $description \
                         -additional_properties $attributes]

    bcms::revision::set_revision_status \
        -revision_id $revision_id \
        -status "live"

} -edit_request {

    error TODO
    
} -edit_data {

    error TODO
    
} -after_submit {
    ad_returnredirect object-list
    ad_script_abort
}
