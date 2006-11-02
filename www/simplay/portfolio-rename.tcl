ad_page_contract {
    Rename a document in the portfolio of a simulation case.

    @author Peter Marklund
} {
    case_id:integer
    role_id:integer
    document_id:integer
    {return_url {[export_vars -base portfolio { case_id role_id }]}}
}

permission::require_write_permission -object_id $document_id

simulation::case::assert_user_may_play_role -case_id $case_id -role_id $role_id

set page_title [_ simulation.Rename_Document]
set context [list [list . [_ simulation.SimPlay]] \
                   [list [export_vars -base case { case_id role_id }] \
                         [_ simulation.Case]] $page_title]

set workflow_id [workflow::case::get_element -case_id $case_id -element workflow_id]

set role_options [list]
foreach one_role_id [workflow::case::get_user_roles -case_id $case_id] {
    lappend role_options [list [workflow::role::get_element -role_id $one_role_id -element pretty_name] $one_role_id]
}

set focus "document.title"

ad_form -name document -export { case_id role_id workflow_id return_url } \
    -cancel_url $return_url \
    -form {
      {document_id:key}
      {title:text(text),optional
          {label "Title"}
          {html {size 50}}
          {help_text "[_ simulation.leave_blank]"}
      }
    } -select_query {
      select title 
      from sim_case_role_object_map
      where object_id = :document_id and
        case_id = :case_id and
        role_id = :role_id
    } -on_submit {
        db_dml rename_document "update sim_case_role_object_map
                                set title = :title
                                where role_id = :role_id and
                                  case_id = :case_id and
                                  object_id = :document_id"

        ad_returnredirect $return_url
    }