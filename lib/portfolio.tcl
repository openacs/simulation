simulation::include_contract {
    Displays a list of documents mapped to roles in this case.

    @author Peter Marklund
    @creation-date 2003-12-20
    @cvs-id $Id$
} {
    case_id {}
    role_id {}
    portfolio_orderby { required_p 0 }
}


simulation::case::assert_user_may_play_role -case_id $case_id -role_id $role_id

set upload_url [export_vars -base document-upload { case_id role_id  }]

if { [exists_and_not_null case_id] } {
    set user_roles [workflow::case::get_user_roles -case_id $case_id]
} else {
    set user_roles [list]
}

if { [exists_and_not_null case_id] } {
    set num_enabled_actions [db_string select_num_enabled_actions { 
        select count(*) 
        from   workflow_case_enabled_actions 
        where  case_id = :case_id
    }]
    set complete_p [expr $num_enabled_actions == 0]
} else {
    set complete_p 0
}

if { [string match $complete_p "0"] && [exists_and_not_null role_id] } {
    set actions [list [_ simulation.Upload_a_document] $upload_url]
} else {
    set actions [list]
}

template::list::create \
    -name documents \
    -multirow documents \
    -no_data [_ simulation.lt_There_are_no_document] \
    -actions $actions \
    -filters { case_id {} role_id {} } \
    -orderby_name portfolio_orderby \
    -elements {
        document_title {
            label {[_ simulation.Document]}
            link_url_col document_url
	    orderby upper(cr.title)
        }        
	publish_date {
	    label {[_ simulation.Upload_date]}
	    orderby cr.publish_date
	    display_col publish_date_pretty
	}
	mime_type {
	    label "[_ simulation.mime_type]"
	    orderby cr.mime_type
	}
	content_length {
	    label "[_ simulation.File_size]"
	    orderby cr.content_length
	}
    } 

db_multirow -extend { document_url publish_date_pretty } documents select_documents "
    select scrom.object_id as document_id,
           ci.name  as document_name,
           cr.title as document_title,
           wr.pretty_name as role_name,
           cr.publish_date as publish_date,
           cr.mime_type,
           cr.content_length
    from sim_case_role_object_map scrom,
         workflow_roles wr,
         cr_items ci,
         cr_revisions cr
    where scrom.case_id = :case_id
      and scrom.role_id = :role_id
      and scrom.role_id = wr.role_id
      and scrom.object_id = ci.item_id
      and ci.live_revision = cr.revision_id
    [template::list::orderby_clause -orderby -name "documents"]
" {
    set document_url [simulation::object::content_url -name $document_name]

    set publish_date_pretty [lc_time_fmt $publish_date "%x %X"]    
}
