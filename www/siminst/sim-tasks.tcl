ad_page_contract {
    Show all task descriptions for editing.

    @author Joel Aufrecht
} {
    workflow_id:integer
}

set user_id [auth::require_login]

set page_title "Edit Task Descriptions"
set context [list [list "." "SimInst"] $page_title]
set old_name [workflow::get_element -workflow_id $workflow_id -element pretty_name]
acs_user::get -user_id $user_id -array user_array

######################################################################
#
# tasks
#
# a form showing description for all tasks in a sim
#
# TODO: display mode doesn't exist yet - all display is through edit mode
#
######################################################################

#---------------------------------------------------------------------
# tasks form
#---------------------------------------------------------------------



