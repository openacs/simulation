ad_page_contract {

  @creation-date 2003-10-13
  @cvs-id $Id$
} {
} -properties {
}

# fake the multirow for active objects
multirow create cases case_id case_name task_count
multirow append cases 1 "Case One" 0
multirow append cases 1 "Case Two" 2

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


