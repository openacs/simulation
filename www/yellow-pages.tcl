ad_page_contract {

  @creation-date 2003-10-13
  @cvs-id $Id$
} {
    parent_id:optional
    {orderby "title,asc"}
    {type:optional}
    yp_orderby:optional
}

if { ![exists_and_not_null yp_orderby] } {
    set yp_orderby 0
}

set page_title "Yellow Pages"
set context [list $page_title]
