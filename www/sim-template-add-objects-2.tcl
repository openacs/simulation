ad_page_contract {

  @creation-date 2003-10-13
  @cvs-id $Id$
} {
    workflow_id
    item_id
}

set package_id [ad_conn package_id]

######################################################################
#
# add the object to the workflow
#
######################################################################

db_dml add_object_to_workflow_insert "
insert into sim_workflow_object_map
values (:workflow_id, :item_id)
"

ad_returnredirect "sim-template-edit?workflow_id=$workflow_id"