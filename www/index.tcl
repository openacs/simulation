ad_page_contract {

  @creation-date 2003-10-13
  @cvs-id $Id$
} {
} -properties {
}

# phase2: sortable, filterable
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

# phase2: a list of cases for which the user has a role, along with a count of the 
# number of active tasks for that role 

db_multirow cases cases_sql {
    select 'case one' as case_name,
           2 as task_count
}

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

db_multirow cases cases_sql {
    select 'case one', 'case two' as case_name,
           0,2 as task_count
    from dual
}
