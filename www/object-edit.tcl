ad_page_contract {
    Add/edit object.

    @creation-date 2003-10-13
    @cvs-id $Id$
} {
    item_id:integer,optional
    {parent_id:integer {[bcms::folder::get_id_by_package_id -parent_id 0]}}
    {content_type {sim_prop}}
}

#TODO: object type should be non-editable for non-new things

#---------------------------------------------------------------------
# Determine if we are in edit mode or display mode
#---------------------------------------------------------------------
# this is prototype code to correct for get_action's apparent
# unreliability

#set mode [template::form::get_action sim_template]
#if { ![exists_and_not_null workflow_id]} {
#    set mode "add"
#} else {
#    # for now, use edit mode in place of display mode
#    #    set mode "display"
#    set mode "edit"
#}

if { ![ad_form_new_p -key item_id] } {
    # Get data for existing object
    array set item_info [bcms::item::get_item -item_id $item_id -revision live]
    item::get_revision_content $item_info(revision_id)
    set content_type $item_info(content_type)
    set page_title "Edit Sim Object"
} else {
    set page_title "Create Sim Object"
}
set context [list [list "object-list" "Sim Objects"] $page_title]


######################################################################
#
# object
#
# A form for editing and viewing sim objects
#
######################################################################

ad_form -name object -cancel_url object-list -form {
    {item_id:key}
    {parent_id:integer(hidden),optional}
    {content_type:text(radio)
        {label "Type"}
        {options {[simulation::object_type::get_options]}}
        {mode "display"}
    }
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


#####
#
# Content edit/upload method
#
# Add a form widget appropriate for the content attribute of the object type
#
#####

array set content_method {
    sim_character richtext
    sim_home richtext
    sim_prop richtext
    sim_stylesheet textarea
}

if { ![info exists content_method($content_type)] } {
    set content_method($content_type) "richtext"
}
switch $content_method($content_type) {
    richtext {
        ad_form -extend -name object -form {
            {content_elm:richtext(richtext),optional
                {label "Content"}
                {html {cols 60 rows 8}}
            }
        }
    }
    textarea {
        ad_form -extend -name object -form {
            {content_elm:text(textarea),optional
                {label "Content"}
                {html {cols 60 rows 8}}
            }
        }
    }
    default {
        error "The '$content_method($content_type)' content input method has not yet been implemented"
    }
}



#####
#
# Dynamic attributes for the content type
#
# Look up the other attributes for this content type and put them on the form
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

array set form_references {
    sim_character.stylesheet sim_stylesheet
    sim_home.stylesheet sim_stylesheet
    sim_prop.stylesheet sim_stylesheet
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
    set elm_name attr__${content_type}__${attribute_name}
    set elm_datatype $form_datatype($datatype)
    set elm_widget $form_widget($datatype)
    # LARS TODO: This needs to be specifiable in the attribute declaration
    set elm_optional_p 1

    set extra $form_extra($datatype)
    if { [exists_and_not_null form_references(${content_type}.${attribute_name})] } {
        set elm_widget select
        set elm_ref_type $form_references(${content_type}.${attribute_name})

        # LARS TODO: We need to be able to scope this to a package, 
        # possibly filter by other things, control the sort order,
        # we need to be able to control what the label looks like (e.g. include email for users)
        # and it needs to be intelligent about scaling issues

        set content_type_p [db_string content_type_p { 
            select count(*) 
            from   acs_object_type_supertype_map
            where  object_type = :elm_ref_type
            and    ancestor_type = 'content_revision'
        }]

        if { $content_type_p } {
            set options [db_list_of_lists select_options { 
                select r.title,
                       i.item_id
                from   cr_items i, cr_revisions r
                where  i.content_type = :elm_ref_type
                and    r.revision_id = i.live_revision
                order  by r.title
            }]
        } else {
            set options [db_list_of_lists select_options { 
                select acs_object__name(object_id),
                       object_id
                from   acs_objects
                where  object_type = :elm_ref_type
                order  by acs_object__name(object_id)
            }]
        }

        set options [concat {{{--None--} {}}} $options]
        lappend extra { options \$options }
    }

    set elm_decl "${elm_name}:${elm_datatype}($elm_widget)"
    if { $elm_optional_p } {
        append elm_decl ",optional"
    }
    
    ad_form -extend -name object -form \
            [list [concat [list $elm_decl [list label \$pretty_name]] $extra]]
}


ad_form -extend -name object -new_request {
    # Set element values from local vars
} -on_submit {

    set attributes [list]
    foreach attribute_name $attr_names {
        lappend attributes $attribute_name [set attr__${content_type}__${attribute_name}]
    }

} -new_data {
    
    permission::require_permission -privilege create -object_id [ad_conn package_id]

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
    
    switch $content_method($content_type) {
        richtext {
            set content_text [template::util::richtext::get_property contents $content_elm]
            set mime_type [template::util::richtext::get_property format $content_elm]
        }
        textarea {
            set content_text $content_elm
            set mime_type "text/plain"
        }
    }

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
    
    permission::require_write_permission -object_id $item_id

    foreach elm { title name description } {
        set $elm $content($elm)
    }
    
    foreach attribute_name $attr_names {
        set attr__${content_type}__${attribute_name} $content($attribute_name)
    }
    
    switch $content_method($content_type) {
        richtext {
            set content_elm [template::util::richtext::create $content(text) $content(mime_type)]
        } 
        textarea {
            set content_elm $content(text)
        }
    }
} -edit_data {

    switch $content_method($content_type) {
        richtext {
            set content_text [template::util::richtext::get_property contents $content_elm]
            set mime_type [template::util::richtext::get_property format $content_elm]
        }
        textarea {
            set content_text $content_elm
            set mime_type "text/plain"
        }
    }


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
