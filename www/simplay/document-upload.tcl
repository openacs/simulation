ad_page_contract {
    Upload a document to the portfolio of a simulation case.

    @author Peter Marklund
} {
    case_id:integer
    role_id:integer
    item_id:optional
}

set page_title "Upload new document to portfolio"
set context [list [list . "SimPlay"] [list [export_vars -base case { case_id role_id }] "Case"] $page_title]

set workflow_id [workflow::case::get_element -case_id $case_id -element workflow_id]

set role_options [list]
foreach one_role_id [workflow::case::get_user_roles -case_id $case_id] {
    lappend role_options [list [workflow::role::get_element -role_id $one_role_id -element pretty_name] $one_role_id]
}

ad_form -name document -export { case_id role_id workflow_id } -html {enctype multipart/form-data} -form {
    {item_id:key}
}

if { [llength $role_options] > 1 } {
    ad_form -extend -name document -form {
        {role_id:text(select)
            {label "Role"}
            {options $role_options}
        }
    }
    set focus "document.role_id"
} else {
    set focus "document.document_file"
}

ad_form -extend -name document -form {
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

        if { ![exists_and_not_null role_id] } {
            set role_id [lindex [lindex $role_options 0] 1]
        }

        set relation_tag "portfolio"
        db_dml add_document_to_portfolio {
            insert into sim_case_role_object_map
            (case_id, object_id, role_id, relation_tag)
            values
            (:case_id, :item_id, :role_id, :relation_tag)
        }
    }
    
    ad_returnredirect [export_vars -base case { case_id role_id }]
}
