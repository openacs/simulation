ad_library {
    Procs to handle sim_messages
}

namespace eval simulation {}
namespace eval simulation::message {}


ad_proc -public simulation::message::new {
    -from_role_id:required
    -to_role_id:required
    -case_id:required
    -subject:required
    {-body {}}
    {-body_mime_type "text/plain"}
    {-item_id {}}
    {-parent_id {}}
    {-content_type "sim_message"}
    {-item_name ""}
    {-attachments ""}
} {
    Create new simulation message.
    
    @return item_id of the new message
} {
    db_transaction {
        
        if { [empty_string_p $parent_id] } {
            set parent_id [bcms::folder::get_id_by_package_id -parent_id 0]
        }
        
        if { [empty_string_p $item_id] } {
            set item_id [db_nextval "acs_object_id_seq"]
        }

        if { [empty_string_p $item_name] } {
            set item_name "message_$item_id"
        }
        
        set item_id [bcms::item::create_item \
                         -item_id $item_id \
                         -item_name $item_name \
                         -parent_id $parent_id \
                         -content_type $content_type]
        
        set attributes [list \
                            [list from_role_id $from_role_id] \
                            [list to_role_id $to_role_id] \
                            [list case_id $case_id]]
        
        set revision_id [bcms::revision::add_revision \
                             -item_id $item_id \
                             -title $subject \
                             -content_type "sim_message" \
                             -mime_type $body_mime_type \
                             -content $body \
                             -additional_properties $attributes]
        
        bcms::revision::set_revision_status \
            -revision_id $revision_id \
            -status "live"

        
        foreach attachment_id $attachments {
            bcms::item::relate_item \
                -relation_tag "attachment" \
                -item_id $item_id \
                -related_object_id $attachment_id
        }

    }
    
    return $item_id
}
