ad_page_contract {

  @creation-date 2003-10-13
  @cvs-id $Id$
} {
} -properties {
}


multirow cases 

template::list::create \
    -name cases \
    -multirow cases \
    -elements {
	case_name { 
	    label "Case"
	    orderby case_name
	}
	task_count {
	    label "Tasks"
	    orderby task_count
	}
    }

