ad_page_contract {
    Upload a document to the portfolio of a simulation case.

    @author Peter Marklund
} {
    case_id:integer
    role_id:integer
    item_id:optional
}

simulation::case::assert_user_may_play_role -case_id $case_id -role_id $role_id

set page_title "Upload new document to portfolio"
set context [list [list . "SimPlay"] [list [export_vars -base case { case_id role_id }] "Case"] $page_title]

set workflow_id [workflow::case::get_element -case_id $case_id -element workflow_id]

set role_options [list]
foreach one_role_id [workflow::case::get_user_roles -case_id $case_id] {
    lappend role_options [list [workflow::role::get_element -role_id $one_role_id -element pretty_name] $one_role_id]
}

set focus "document.document_file"

ad_form -name document -export { case_id role_id workflow_id } -html {enctype multipart/form-data} \
    -form [simulation::ui::forms::document_upload::form_block] \
    -on_submit {

        simulation::ui::forms::document_upload::insert_document \
            $case_id $role_id $item_id $document_file $title

        ad_returnredirect [export_vars -base case { case_id role_id }]
    }
