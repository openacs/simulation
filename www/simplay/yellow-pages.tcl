ad_page_contract {

  @creation-date 2003-10-13
  @cvs-id $Id$
} {
    parent_id:optional
    {type:optional}
    yp_orderby:optional
    case_id:integer,notnull
    role_id:integer,notnull
}

if { ![exists_and_not_null yp_orderby] } {
    set yp_orderby 0
}

simulation::case::get -case_id $case_id -array case
set case_url [export_vars -base case { case_id role_id }]

set page_title [_ simulation.Yellow_Pages]

set workflow_id [simulation::case::get_element -case_id $case_id \
                   -element workflow_id]

set simulation_name [simulation::template::get_element \
                      -workflow_id $workflow_id -element pretty_name]
set sim_title [_ simulation.simulation_name]
set context [list [list . [_ simulation.SimPlay]] [list [export_vars -base case {case_id role_id }] $sim_title] $page_title]