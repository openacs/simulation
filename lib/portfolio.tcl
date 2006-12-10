simulation::include_contract {
    Displays a list of documents mapped to roles in this case.

    @author Peter Marklund
    @creation-date 2003-12-20
    @cvs-id $Id$
} {
    case_id {}
    role_id {}
    deleted_p { default_value 0 }
    show_actions_p { default_value 1 }
    portfolio_orderby { default_value document_title }
}


simulation::case::assert_user_may_play_role -case_id $case_id -role_id $role_id

set package_id [ad_conn package_id]
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

if { [string match $complete_p "0"] && [exists_and_not_null role_id] && $show_actions_p } {
    set actions [list [_ simulation.Upload_a_document] $upload_url]
} else {
    set actions [list]
}

set elements {
  document_title {
    label {[_ simulation.Document]}
    link_url_col document_url
	  orderby "upper(COALESCE(scrom.title, cr.title))"
  }        
	publish_date {
	    label {[_ simulation.Upload_date]}
	    orderby cr.publish_date
	    display_col publish_date_pretty
	}
	mime_type {
	    label "[_ simulation.Mime_type]"
	    orderby cr.mime_type
	}
	content_length {
	    label "[_ simulation.File_size]"
	    orderby cr.content_length
	}
}

set extend { document_url publish_date_pretty delete delete_url rename rename_url }

if { $deleted_p } {
    lappend elements delete
    lappend elements {
      link_url_col delete_url
      label {[_ simulation.Undelete]}
    }
    
} else {
    lappend elements delete
    lappend elements {
      label {[_ simulation.Delete]}
      display_template {
        <a href="@documents.delete_url@" title="#simulation.Delete#"><img src="/resources/acs-subsite/Delete16.gif" alt="delete" /></a>
      }
    }
    
}

lappend elements rename
lappend elements {
  label {[_ simulation.Rename]}
  display_template {
    <a href="@documents.rename_url@" title="#simulation.Rename#"><img src="/resources/acs-subsite/Edit16.gif" alt="Rename" /></a>
  }
}

template::list::create \
    -name documents \
    -multirow documents \
    -no_data [_ simulation.lt_There_are_no_document] \
    -actions $actions \
    -filters { case_id {} role_id {} } \
    -orderby_name portfolio_orderby \
    -elements $elements

db_multirow -extend $extend documents select_documents "
    select scrom.object_id as document_id,
           ci.name  as document_name,
           COALESCE(scrom.title, cr.title) as document_title,
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
      and [ad_decode $deleted_p 1 "" "not"] exists
        (select 1 from sim_portfolio_trash spt
         where spt.object_id = scrom.object_id and
           spt.case_id = :case_id and
           spt.role_id = :role_id)
    [template::list::orderby_clause -orderby -name "documents"]
" {
    set document_url [simulation::object::content_url -name $document_name]
    
    if { $deleted_p } {
      set delete [_ simulation.Undelete]
    } else {
      set delete [_ simulation.Delete]
    }
    
    set undelete_p $deleted_p
    
    set delete_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/portfolio-delete" { case_id role_id document_id undelete_p}]
    
    set rename [_ simulation.Rename]
    set rename_url [export_vars -base "[apm_package_url_from_id $package_id]simplay/portfolio-rename" { case_id role_id document_id}]

    set publish_date_pretty [lc_time_fmt $publish_date "%x %X"]    
}
