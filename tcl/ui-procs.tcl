ad_library {
    UI related procs.

    @author Peter Marklund
    @creation-date 2004-01-20
    @cvs-id $Id$
}

namespace eval simulation::ui {}
namespace eval simulation::ui::simplay {}
namespace eval simulation::ui::forms::document_upload {}

ad_proc -public simulation::ui::forms::document_upload::form_block {} {
    Return the form block for the document upload form.

    @author Peter Marklund
} {
    return {
        {item_id:key}
        {document_file:file(file)
            {label "Document file"}
        }
        {title:text(text)
            {label "Title"}
            {html {size 50}}
        }
    }
}

ad_proc -public simulation::ui::forms::document_upload::documents_element_value { 
    {-content_p:boolean {0}}
    action_id 
} {
    Get a piece of HTML with links to documents for the documents form element.    
} {
    set documents "<ul>"
    
    db_foreach documents {
        select cr.title as object_title,
        ci.name as object_name
        from   sim_task_object_map m,
        cr_items ci,
        cr_revisions cr
        where  m.task_id = :action_id
        and    m.relation_tag = 'attachment'
        and    ci.item_id = m.object_id
        and    cr.revision_id = ci.live_revision
        order by m.order_n
    } {
	if { !$content_p } {
	    set object_url [simulation::object::url \
				-name $object_name]
	} else {
	    set object_url [simulation::object::content_url \
				-name $object_name]
	}
        append documents "<li><a href=\"$object_url\">$object_title</a></li>"
    }

    append documents "</ul>"

    return $documents
}

ad_proc -public simulation::ui::forms::document_upload::documents_element_value_content { 
    action_id 
} {
    Get a piece of HTML with links to documents' content for the documents form element.    
} {
    set documents "<ul>"
    
    db_foreach documents {
        select cr.title as object_title,
        ci.name as object_name
        from   sim_task_object_map m,
        cr_items ci,
        cr_revisions cr
        where  m.task_id = :action_id
        and    m.relation_tag = 'attachment'
        and    ci.item_id = m.object_id
        and    cr.revision_id = ci.live_revision
        order by m.order_n
    } {
	set object_url [simulation::object::content_url \
			    -name $object_name]
        append documents "<li><a href=\"$object_url\">$object_title</a></li>"
    }

    append documents "</ul>"

    return $documents
}


ad_proc -public simulation::ui::forms::document_upload::insert_document {
    case_id
    role_id
    item_id 
    document_file 
    title 
    {entry_id {}}
} {
    Does the document insertion in the DB.

    @author Peter Marklund
} {
    db_transaction {

        set parent_id [bcms::folder::get_id_by_package_id -parent_id 0]

        set existing_items [db_list select_items { select name from cr_items where parent_id = :parent_id }]
        set name [util_text_to_url -existing_urls $existing_items -text $title]

        set content_type sim_prop
        set storage_type file

        set item_id [bcms::item::create_item \
                         -item_id $item_id \
                         -item_name $name \
                         -parent_id $parent_id \
                         -content_type $content_type \
                         -storage_type $storage_type]
        
        set revision_id [bcms::revision::upload_file_revision \
                             -item_id $item_id \
                             -title $title \
                             -content_type $content_type \
                             -upload_file $document_file]

        bcms::revision::set_revision_status \
            -revision_id $revision_id \
            -status "live"

        set relation_tag "portfolio"
        db_dml add_document_to_portfolio {
            insert into sim_case_role_object_map
            (case_id, object_id, role_id, relation_tag, entry_id)
            values
            (:case_id, :item_id, :role_id, :relation_tag, :entry_id)
        }
    }
}

ad_proc -public simulation::ui::forms::document_upload::check_mime {
    -document_file
} {
    Checks that the mime type of the given file can be found in the cr_mime_types
    table. Using this avoids bombs later on in the upload process

    @param document_file the file being uploaded

    @author Jarkko Laine (jarkko@jlaine.net)
} {
    set upload_filename [template::util::file::get_property filename $document_file]
    
    if { ![exists_and_not_null mime_type] } {
	set mime_type [template::util::file::get_property mime_type $document_file]
    }

    if { ![exists_and_not_null mime_type] } {
	set mime_type [cr_filename_to_mime_type -create $upload_filename]
    }
    
    set mime_count [db_string get_mime {
	select count(*) from cr_mime_types where mime_type = :mime_type}]
    
    if { $mime_count > 0 } {
	return 1
    } else {
	return 0
    } 
}

ad_proc -public simulation::ui::forms::document_upload::add_mime {
    -document_file
} {
    Tries to add the mime type of a file to cr_mime_types unless
    it already exists there.

    @param document_file the file being uploaded

    @author Jarkko Laine (jarkko@jlaine.net)
} {
    set upload_filename [template::util::file::get_property filename $document_file]
    set extension [string tolower [string trimleft [file extension $upload_filename] "."]]
    set orig_mime_type [template::util::file::get_property mime_type $document_file]

    cr_create_mime_type -extension $extension -mime_type $orig_mime_type
}