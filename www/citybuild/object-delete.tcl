ad_page_contract {
    Delete an object.
} {
    {confirm_p:boolean "f"}
    item_id:integer
    {return_url "."}
}

array set item [bcms::item::get_item -item_id $item_id -revision live]

if { [template::util::is_true $confirm_p] } {
    permission::require_write_permission -object_id $item_id    
    bcms::item::delete_item -item_id $item_id

    ad_returnredirect -message "\"$item(title)\" has been deleted." $return_url
    ad_script_abort
}


set page_title "Delete object \"$item(title)\""
set context [list [list "." "CityBuild"] $page_title]

set use_workflows [db_list char_use { select wf.pretty_name
from sim_roles sr, workflow_roles wr, workflows wf
where sr.role_id = wr.role_id and
      wr.workflow_id = wf.workflow_id and
      sr.character_id = :item_id
}]

set deletable 1
set wfs 0
set wf_length [llength $use_workflows]

if { $wf_length > 0 } {
    if { $wf_length > 5 } {
	set rest [lrange $use_workflows 5 [expr $wf_length-1]]
	set use_workflows [lrange $use_workflows 0 4]
	set rest_length [llength $rest]
	lappend use_workflows "([_ simulation.and_rest_length_more])"
    }
    set wf_string [join $use_workflows ", "]
    set wfs 1
    set deletable 0
}

set relations [db_list relations { 
select  case when cir.related_object_id = :item_id
          then content_item__get_title(cir.item_id)
          else content_item__get_title(cir.related_object_id)
        end as title
from cr_item_rels cir
where item_id = :item_id or
      related_object_id = :item_id
}]

set rels 0
if { [llength $relations] > 0 } {
    set rel_string [join $relations ", "]
    set rels 1
    set deletable 0
}

set delete_url [export_vars -base [ad_conn url] { item_id return_url { confirm_p 1 } }]
set cancel_url $return_url
