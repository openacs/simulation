ad_page_contract {
    TODO...explain what this page is about

    @author Peter Marklund
} {
    workflow_id:integer
}

workflow::get -workflow_id $workflow_id -array workflow_array
set page_title "Tasks for $workflow_array(pretty_name)"
set context [list [list "." "SimInst" ] $page_title]

db_multirow -extend { description_html prop_missing_count } tasks select_taks {
    select a.action_id,
           a.short_name,
           a.pretty_name,
           a.description,
           a.description_mime_type,
           st.attachment_num,
           (select count(*)
            from   sim_task_object_map stom
            where  stom.task_id = st.task_id) as prop_not_empty_count
    from   workflow_actions a,
           sim_tasks st
    where  a.workflow_id = :workflow_id
    and    st.task_id = a.action_id
} {
    set description_html [ad_html_text_convert -maxlen 100 -from $description_mime_type -- $description]
    set prop_missing_count [expr $attachment_num - $prop_not_empty_count]
}

# TODO: Honor description_mime_type, fancy truncate

template::list::create \
    -name "tasks" \
    -elements {
        pretty_name {
            label "Name"
            link_url_eval {[export_vars -base task-edit { action_id }]}
        }
        description {
            label "Description"
            display_template {@tasks.description_html;noquote@}
        }
        attachment_num {
            label "Number of attachments"
            display_template {<if @tasks.attachment_num@ gt 0>@tasks.attachment_num@</if>}
        }
        prop_missing_count {
            label "Missing attachments"
            display_template {<if @tasks.prop_missing_count@ gt 0><b>@tasks.prop_missing_count@</b></if>}
        }
    }
