ad_page_contract {
    Upload a document to the portfolio of a simulation case.

    @author Peter Marklund
} {
    case_id:integer
    item_id:optional
}

set page_title "Upload new document to portfolio"
set context [list [list . "SimPlay"] $page_title]

# TODO: should there be a workflow::case::get_workflow_id?
set workflow_id [workflow::case::fsm::get_element -case_id $case_id -element workflow_id]

ad_form -name document -export { case_id workflow_id } -html {enctype multipart/form-data} -form {
    {item_id:key}

    {role_short_name:text(select)
        {label "Role"}
        {options {[workflow::role::get_options -workflow_id $workflow_id]}}
    }
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
} -on_submit {

    db_transaction {

        set parent_id [bcms::folder::get_id_by_package_id -parent_id 0]

        # TODO: this is a copy-and-paste from object-edit.tcl
        set existing_items [db_list select_items { select name from cr_items where parent_id = :parent_id }]
        set name [util_text_to_url -existing_urls $existing_items -text $title]

        set content_type sim_prop
        set storage_type file

        #error "$item_id $name $parent_id $content_type $storage_type"

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

        set role_id [workflow::role::get_id -short_name $role_short_name -workflow_id $workflow_id]

        # TODO: Tcl proc?
        # TODO: what should relation_tag be?
        set relation_tag "dummy"
        db_dml add_document_to_portfolio {
            insert into sim_case_role_object_map
            (case_id, object_id, role_id, relation_tag)
            values
            (:case_id, :item_id, :role_id, :relation_tag)
        }
    }
    
    ad_returnredirect [export_vars -base case { case_id }]
}
