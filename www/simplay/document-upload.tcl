ad_page_contract {
    Upload a document to the portfolio of a simulation case.

    @author Peter Marklund
} {
    case_id:integer
    role_id:integer
    item_id:optional
    {return_url {[export_vars -base case { case_id role_id }]}}
}

simulation::case::assert_user_may_play_role -case_id $case_id -role_id $role_id

set page_title [_ simulation.lt_Upload_new_document_t]
set context [list [list . [_ simulation.SimPlay]] \
                   [list [export_vars -base case { case_id role_id }] \
                         [_ simulation.Case]] \ 
                   $page_title]

set workflow_id [workflow::case::get_element -case_id $case_id -element workflow_id]

set role_options [list]
foreach one_role_id [workflow::case::get_user_roles -case_id $case_id] {
    lappend role_options [list [workflow::role::get_element -role_id $one_role_id -element pretty_name] $one_role_id]
}

set focus "document.document_file"

if { [exists_and_not_null document_file] && ![simulation::ui::forms::document_upload::check_mime -document_file $document_file] } {
    simulation::ui::forms::document_upload::add_mime -document_file $document_file
}

ad_form -name document -export { case_id role_id workflow_id return_url } -html {enctype multipart/form-data} \
    -cancel_url $return_url \
    -form [simulation::ui::forms::document_upload::form_block] \
    -validate {
	{document_file 
	    {[simulation::ui::forms::document_upload::check_mime -document_file $document_file]}
	    "[_ simulation.lt_The_mime_type_of_your] [_ simulation.lt_Please_contact_______] 
             (<a href='mailto:[ad_host_administrator]'>[ad_host_administrator]</a>)
             [_ simulation.lt_if_you_think_youre_up]"
	}
    } -on_submit {

        simulation::ui::forms::document_upload::insert_document \
            $case_id $role_id $item_id $document_file $title

        ad_returnredirect $return_url
    } 