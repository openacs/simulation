ad_page_contract {
    Add/edit object.

    @creation-date 2003-10-13
    @cvs-id $Id$
} {
    item_id:integer,optional
    {parent_id:integer {[bcms::folder::get_id_by_package_id -parent_id 0]}}
    {content_type {sim_prop}}
}

auth::require_login

if { ![ad_form_new_p -key item_id] } {
    # Get data for existing object
    array set item_info [bcms::item::get_item -item_id $item_id -revision live]
    item::get_revision_content $item_info(revision_id)

    if {! [info exists content(text)] } {
        set content(text) ""
    }
    set content_type $item_info(content_type)
    set page_title "Edit Sim Object"
} else {
    set page_title "Create Sim Object"
}
set context [list [list "." "CityBuild"] $page_title]

######################################################################
#
# object
#
# A form for editing and viewing sim objects
#
######################################################################

ad_form -name object -cancel_url "." -html {enctype multipart/form-data} -form {
    {item_id:key}
    {parent_id:integer(hidden),optional}
}

if { [ad_form_new_p -key item_id] } {
    ad_form -extend -name object -form {
        {content_type:text(radio)
            {label "Type"}
            {options {[simulation::object_type::get_options]}}
            {html {onChange "javascript:acs_FormRefresh('object');"}}
        }
    }
} else {
    ad_form -extend -name object -form {
        {content_type:text(select)
            {label "Type"}
            {options {[simulation::object_type::get_options]}}
            {mode display}
        }
    }
}

ad_form -extend -name object -form {
    {title:text
        {label "Title"}
        {html {size 50}}
    }
    {name:text,optional
        {label "URI"}
        {html {size 50}}
        {help_text {[ad_decode [ad_form_new_p -key item_id] 1 "Leave blank to default to Title.  This will become part of the URL for the object." ""]}}
        {mode {[ad_decode [ad_form_new_p -key item_id] 1 "edit" "display"]}}
    }
    {description:text(textarea),optional
        {label "Description"}
        {html {cols 60 rows 8}}
    }
}



#---------------------------------------------------------------------
# Define meta data for the content types and their attributes. 
#---------------------------------------------------------------------

# Define the metadata in an easy format
# this is prototype stuff

set content_metadata {
    sim_character {
        content_method richtext
        relations {
            works_for {
                label "Works For"
            }
            resides_at {
                label "Resides at"
            }
            image {
                label "Image"
            }
            stylesheet {
                label "Stylesheet"
            }
            thumbnail {
                label "Thumbnail"
            }
            image {
                label "Image"
            }
        }
    }
    sim_location {
        content_method richtext
        relations {
            stylesheet {
                label "Stylesheet"
            }
            thumbnail {
                label "Thumbnail"
            }
            image {
                label "Image"
            }
            letterhead {
                label "Letterhead"
            }
            logo {
                label "Logo"
            }
            is_located_in {
                label "Located inside (optional)"
            }
        }
        attributes {
            on_map_p {
                write_privileges "sim_set_map_p"
            }
        }
    }
    sim_prop {
        content_method richtext
        relations {
            associated {
                label "Associated with"
            }
            stylesheet {
                label "Stylesheet"
            }
            thumbnail {
                label "Thumbnail"
            }
            image {
                label "Image"
            }
            logo {
                label "Logo"
            }
            letterhead {
                label "Letterhead"
            }
        }
        attributes {
            on_map_p {
                write_privileges "sim_set_map_p"
            }
        }
    }
    sim_stylesheet {
        content_method textarea
        mime_type text/css
    }
    image {
        content_method upload
        attributes {
            width  {
                widget hidden
            }
            height {
                widget hidden
            }
        }
    }
}


# Terminology:
#
#      content_type , property
# e.g. sim_character, content_method
#
#      content_type , entry_type, entry     , property
# e.g. sim_character, attributes, stylesheet, references


#---------------------------------------------------------------------
# Make metadata more accessible. Should go into library.
#---------------------------------------------------------------------

# Now munge the above spec into something more efficient to use
array set content_metadata_struct [list]
foreach { ct ct_spec } $content_metadata {
    foreach { prop prop_spec } $ct_spec {
        switch $prop {
            attributes - relations {
                # Property with sub-properties. 
                # Has an entry for each attribute/relation/whatever, which then contains properties
                foreach { sub sub_spec } $prop_spec {

                    # Mark the entry as present, even if it doesn't have any properties
                    nsv_set content_metadata_struct $ct,$prop,$sub {}

                    foreach { sub_prop sub_prop_spec } $sub_spec {
                        # key is content_type,attributes,attribute_name,property
                        nsv_set content_metadata_struct $ct,$prop,$sub,$sub_prop $sub_prop_spec
                    }
                }
            }
            default {
                # Single value
                # key is content_type,property
                nsv_set content_metadata_struct $ct,$prop $prop_spec
            }
        }
    }
}

# Define a helper proc to make it easier to get metadata properties
ad_proc get_metadata_property {
    -content_type:required
    -property:required
    -entry_type
    -entry
    {-default ""}
} {
    Get a metadata property for either a content_type or the attribute of a content_type.
} {
    if { [exists_and_not_null entry_type] && [exists_and_not_null entry] } {
        set key $content_type,$entry_type,$entry,$property
    } else {
        set key $content_type,$property
    }
    if { [nsv_exists content_metadata_struct $key] } {
        return [nsv_get content_metadata_struct $key]
    } else {
        return $default
    }
}

ad_proc get_metadata_entries {
    -content_type:required
    -entry_type:required
    {-default ""}
} {
    Get a list of entries inside the metadata. E.g. to get the attributes with metadata for a content_type, say
    get_metadata_keys -content_type $content_type -entry attributes
} {
    set key $content_type,$entry_type

    set result [list]
    set skip_len [expr [string length $key]+1]
    foreach name [nsv_array names content_metadata_struct $key,*] {
        # The part of name after the key
        set extra_name [string range $name $skip_len end]

        # Get the part up to the next comma
        set one_entry [lindex [split $extra_name ,] 0]
        if { [lsearch -exact $result $one_entry] == -1 } {
            lappend result $one_entry
        }
    }
    return $result
}


#---------------------------------------------------------------------
# Content edit/upload method
#
# Add a form widget appropriate for the content attribute of the object type
#---------------------------------------------------------------------

set content_method [get_metadata_property -content_type $content_type -property content_method -default richtext]
switch $content_method  {
    richtext {
        ad_form -extend -name object -form {
            {content_elm:richtext(richtext),optional
                {label "Content"}
                {html {cols 80 rows 16}}
            }
        }
    }
    textarea {
        ad_form -extend -name object -form {
            {content_elm:text(textarea),optional
                {label "Content"}
                {html {cols 80 rows 16}}
            }
        }
    }
    upload {
        ad_form -extend -name object -form {
            {content_file:file(file)
                {label "Content file"}
            }
        }
    }
    default {
        error "The '$content_method' content input method has not yet been implemented"
    }
}

#---------------------------------------------------------------------
# Dynamic attributes for the content type
#
# Look up the other attributes for this content type and put them on the form
#---------------------------------------------------------------------
# LARS: I'm doing this as a proof-of-concept type thing. If it works well
# enough for us, we'll want to generalize and move into acs-content-repository


#---------------------------------------------------------------------
# Internal data structures used for automated form generation. To be moved to library.
#---------------------------------------------------------------------

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
    boolean radio
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
    boolean { 
        {options { {Yes t} {No f}} }
    }
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


#---------------------------------------------------------------------
# Select attributes and add them to the form
#---------------------------------------------------------------------

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
    set $elm_name $default_value
    set elm_datatype $form_datatype($datatype)
    
    set elm_widget [get_metadata_property \
                        -content_type $content_type \
                        -entry_type attributes \
                        -entry $attribute_name \
                        -property widget \
                        -default $form_widget($datatype)]

    set elm_write_privileges [get_metadata_property \
                                  -content_type $content_type \
                                  -entry_type attributes \
                                  -entry $attribute_name \
                                  -property write_privileges \
                                  -default {}]
    set elm_required_p [get_metadata_property \
                            -content_type $content_type \
                            -entry_type attributes \
                            -entry $attribute_name \
                            -property required_p \
                            -default 0]

    set extra $form_extra($datatype)
    set elm_ref_type [get_metadata_property -content_type $content_type -entry_type attributes -entry $attribute_name -property references]
    if { ![empty_string_p $elm_ref_type] } {
        set elm_widget select
        set options [simulation::object::get_object_type_options -object_type $elm_ref_type]
        lappend extra { options \$options }
    }

    if { [llength $elm_write_privileges] > 0 } {
        set mode display
        foreach privilege $elm_write_privileges {
            # HACK: we only check permission on the package
            if { [permission::permission_p -object_id [ad_conn package_id] -privilege $privilege] } {
                set mode edit
                break
            }
        }
        if { [string equal $mode "display"] } {
            lappend extra { mode display }
        }
    }

    set elm_decl "${elm_name}:${elm_datatype}($elm_widget)"
    if { !$elm_required_p } {
        append elm_decl ",optional"
    }
    
    ad_form -extend -name object -form \
        [list [concat [list $elm_decl [list label \$pretty_name]] $extra]]
}


#---------------------------------------------------------------------
# Related objects
#---------------------------------------------------------------------

set rel_elements [list]
db_foreach select_relations {
    select target_type,
           relation_tag,
           min_n,
           max_n
    from   cr_type_relations
    where  content_type = :content_type
    order  by max_n asc, relation_tag
} {
    set label [get_metadata_property -content_type $content_type -entry_type relations -entry $relation_tag -property label]
    set section [get_metadata_property -content_type $content_type -entry_type relations -entry $relation_tag -property section]
    set options [simulation::object::get_object_type_options -object_type $target_type]

    # LARS HACK: This only works for a specific hard-coded max_n
    # We need to generalize so it can be dynamic

    for { set counter 1 } { $counter <= $max_n } { incr counter } {
        set elm_name "rel__${relation_tag}__$counter"
        lappend rel_elements $elm_name

        if { $min_n == 1 && $max_n == 1 } {
            set elm_label $label
        } else {
            set elm_label "$label $counter"
        }
    
        ad_form -extend -name object -form \
            [list \
                 [list $elm_name:integer(select),optional \
                      {label $elm_label} \
                      {section $section} \
                      {options $options} \
                      {html {onChange "javascript:acs_FormRefresh('object');"}} \
                     ] \
                ]
    }
}


#---------------------------------------------------------------------
# Add handlers to the form definition
#---------------------------------------------------------------------

ad_form -extend -name object -new_request {
    # Set element values from local vars
} -on_submit {

    switch $content_method {
        richtext {
            set content_text [template::util::richtext::get_property contents $content_elm]
            set mime_type [template::util::richtext::get_property format $content_elm]
            set storage_type text
        }
        textarea {
            set content_text $content_elm
            set mime_type [get_metadata_property -content_type $content_type -property mime_type -default "text/plain"]
            set storage_type text
        }
        upload {
            # Insertion is handled below
            set storage_type file

            if { [string equal $content_type "image"] } {
                # Figure out height and width
                image::get_info \
                    -filename [template::util::file::get_property tmp_filename $content_file] \
                    -array image_info
                
                set attr__image__height $image_info(height)
                set attr__image__width $image_info(width)
            }
        }
        default {
            error "The '$content_method' content input method has not yet been implemented"
        }
    }

    set attributes [list]
    foreach attribute_name $attr_names {
        set value [set attr__${content_type}__${attribute_name}]
        lappend attributes [list $attribute_name $value]
    }

} -new_data {
    
    # TODO B: For now, assume we are always using this to create global objects -- LARS: Not sure what to do on this
    # When we use this form to create case objects, we should simply check for create permission on the case
    # we could alternately switch to using the cr folder system, in which case:
    #    sim_object_create on package_id is replaced by 'create' on a root folder, and
    #    create on a case is replaced by create on a case's folder

    permission::require_permission -privilege sim_object_create -object_id [ad_conn package_id]

    set existing_items [db_list select_items { select name from cr_items where parent_id = :parent_id }]

    if { [empty_string_p $name] } {
        set name [util_text_to_url -existing_urls $existing_items -text $title]
    } else {
        if { [lsearch $existing_items $name] != -1 } {
            form set_error object name "This name is already in use"
            break
        }
    }

    db_transaction {

        set item_id [bcms::item::create_item \
                         -item_id $item_id \
                         -item_name $name \
                         -parent_id $parent_id \
                         -content_type $content_type \
                         -storage_type $storage_type]
        
        
        switch $content_method {
            upload {
                set revision_id [bcms::revision::upload_file_revision \
                                     -item_id $item_id \
                                     -title $title \
                                     -content_type $content_type \
                                     -upload_file $content_file \
                                     -description $description \
                                     -additional_properties $attributes]
            }
            default {
                set revision_id [bcms::revision::add_revision \
                                     -item_id $item_id \
                                     -title $title \
                                     -content_type $content_type \
                                     -mime_type $mime_type \
                                     -content $content_text \
                                     -description $description \
                                     -additional_properties $attributes]
            }
        }

        bcms::revision::set_revision_status \
            -revision_id $revision_id \
            -status "live"

        foreach elm $rel_elements {
            # LARS HACK ALERT: This isn't a particularly pretty way to find all the related objects in the form
            regexp {__(.+)__} $elm match relation_tag
            regexp {__.+__(.+)$} $elm match order_n
            set related_object_id [set $elm]

            if { ![empty_string_p $related_object_id] } {
                bcms::item::relate_item \
                    -relation_tag $relation_tag \
                    -item_id $item_id \
                    -related_object_id $related_object_id \
                    -order_n $order_n
            }
        }
    }

} -edit_request {
    
    permission::require_write_permission -object_id $item_id

    foreach elm { title name description } {
        set $elm $content($elm)
    }
    
    foreach attribute_name $attr_names {
        set attr__${content_type}__${attribute_name} $content($attribute_name)
    }
    
    switch $content_method {
        richtext {
            set content_elm [template::util::richtext::create $content(text) $content(mime_type)]
        } 
        textarea {
            set content_elm $content(text)
        }
    }

    db_foreach related_objects {
        select related_object_id,
               relation_tag,
               order_n
        from   cr_item_rels
        where  item_id = :item_id
    } {
        ns_log Notice "pm debug $related_object_id $relation_tag"
        set "rel__${relation_tag}__${order_n}" $related_object_id
    }
    
} -edit_data {

    db_transaction {

        switch $content_method {
            upload {
                set revision_id [bcms::revision::upload_file_revision \
                                     -item_id $item_id \
                                     -title $title \
                                     -content_type $content_type \
                                     -upload_file $content_file \
                                     -description $description \
                                     -additional_properties $attributes]
            }
            default {
                set revision_id [bcms::revision::add_revision \
                                     -item_id $item_id \
                                     -title $title \
                                     -content_type $content_type \
                                     -mime_type $mime_type \
                                     -content $content_text \
                                     -description $description \
                                     -additional_properties $attributes]
            }
        }

        bcms::revision::set_revision_status \
            -revision_id $revision_id \
            -status "live"

        # FIXME: The way we do this update is not very pretty: Delete all relations and re-add the new ones
        db_dml delete_all_relations {
            delete from cr_item_rels
            where  item_id = :item_id
        }

        foreach elm $rel_elements {
            # FIXME: LARS HACK ALERT: This isn't a particularly pretty way to find all the related objects in the form
            regexp {__(.+)__} $elm match relation_tag
            regexp {__.+__(.+)$} $elm match order_n
            set related_object_id [set $elm]

            if { ![empty_string_p $related_object_id] } {
                bcms::item::relate_item \
                    -relation_tag $relation_tag \
                    -item_id $item_id \
                    -related_object_id $related_object_id \
                    -order_n $order_n
            }
        }
    }
    
} -after_submit {
    ad_returnredirect "."
    ad_script_abort
}


# LARS: This is a hack to get to execute code on every request, instead of only in certain cases
# The only time we don't want this is when we 

foreach elm $rel_elements {
    set elm_before_html {}
    set elm_after_html {}

    # LARS HACK ALERT: This isn't a particularly pretty way to find all the related objects in the form
    regexp {__(.+)__} $elm match relation_tag
    regexp {__.+__(.+)$} $elm match order_n

    if { [exists_and_not_null $elm] } { 
        set related_object_id [set $elm]

        set rel_obj_name [db_string name { select name from cr_items where item_id = :related_object_id } -default {}]
        if { ![empty_string_p $rel_obj_name] } {
            set thumb_url [simulation::object::content_url -name $rel_obj_name]
            append elm_before_html {<img src="} $thumb_url {" width="50" height="50">}
            append elm_before_html {&nbsp;}
            append elm_before_html {<a href="javascript:document.forms['object'].elements['} $elm {'].value = '';}
            append elm_before_html {acs_FormRefresh('object');" title="} 
            append elm_before_html [ad_quotehtml "Remove this $relation_tag"] 
            append elm_before_html {"><img src="/resources/acs-subsite/Delete24.gif" width="24" height="24" border="0">}
            append elm_before_html {</a>}

            append elm_after_html [ad_quotehtml "<relation tag=\"$relation_tag\" index=\"$order_n\" embed>"]
            append elm_after_html {<a href="javascript:CopyText('}
            append elm_after_html [ad_quotehtml "<relation tag=\"$relation_tag\" index=\"$order_n\" embed>"]
            append elm_after_html {');" title="} 
            append elm_after_html [ad_quotehtml "Copy a tag for this $relation_tag to the clipboard"]
            append elm_after_html {"><img src="/resources/acs-subsite/stock_copy.png" width="24" height="24" }
            append elm_after_html {alt="Copy" border="0"></a>}
        }

    } else {
        append elm_before_html {<img src="/resources/acs-subsite/spacer.gif" height="1" width="50">}
        append elm_before_html {&nbsp;}
        append elm_before_html {<img src="/resources/acs-subsite/spacer.gif" height="1" width="24">}
    }
    append elm_before_html {&nbsp;&nbsp;&nbsp;Choose:}
    
    element set_properties object $elm -before_html $elm_before_html -after_html $elm_after_html
}
