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
        {description:text(textarea),optional
            {label "Description"}
            {html {cols 60 rows 8}}
        }
    }
}

ad_proc -public simulation::ui::forms::document_upload::insert_document {
    case_id
    role_id
    item_id 
    document_file 
    title 
    description
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
                             -upload_file $document_file \
                             -description $description]

        bcms::revision::set_revision_status \
            -revision_id $revision_id \
            -status "live"

        set relation_tag "portfolio"
        db_dml add_document_to_portfolio {
            insert into sim_case_role_object_map
            (case_id, object_id, role_id, relation_tag)
            values
            (:case_id, :item_id, :role_id, :relation_tag)
        }
    }
}
