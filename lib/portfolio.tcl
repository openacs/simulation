simulation::include_contract {
    Displays a list of documents mapped to roles in this case.

    @author Peter Marklund
    @creation-date 2003-12-20
    @cvs-id $Id$
} {
    case_id {}
    role_id {}
}

set upload_url [export_vars -base document-upload { case_id role_id  }]

if { [exists_and_not_null case_id] } {
    set user_roles [workflow::case::get_user_roles -case_id $case_id]
} else {
    set user_roles [list]
}

template::list::create \
    -name documents \
    -multirow documents \
    -no_data "There are no documents." \
    -actions [list "Upload a document" $upload_url] \
    -elements {
        document_title {
            label "Document"
            link_url_col document_url
        }        
    } 

db_multirow -extend { document_url } documents select_documents "
    select scrom.object_id as document_id,
           ci.name  as document_name,
           cr.title as document_title,
           wr.pretty_name as role_name
    from sim_case_role_object_map scrom,
         workflow_roles wr,
         cr_items ci,
         cr_revisions cr
    where scrom.case_id = :case_id
      and scrom.role_id = wr.role_id
      and scrom.object_id = ci.item_id
      and ci.live_revision = cr.revision_id
    order by scrom.order_n
" {
    set document_url [simulation::object::content_url -name $document_name]
}
