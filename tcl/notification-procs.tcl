ad_library {
    Procs related to notifications.

    @author Peter Marklund
    @creation-date 2003-11-10
    @cvs-id $Id$
}

namespace eval simulation::notification {}
namespace eval simulation::notification::xml_map {}
namespace eval simulation::notification::message {}

###############################
#
# simulation::notification::xml_map namespace
# 
###############################

ad_proc -private simulation::notification::xml_map::register {} {
    db_transaction {
        set spec [list \
                      contract_name "NotificationType" \
                      name [sc_name] \
                      aliases {
                          GetURL       simulation::notification::xml_map::get_url
                          ProcessReply simulation::notification::xml_map::process_reply
                      } \
                      owner [simulation::package_key]]
        set sc_impl_id [acs_sc::impl::new_from_spec -spec $spec]

        notification::type::new \
            -all_intervals \
            -all_delivery_methods \
            -sc_impl_id $sc_impl_id \
            -short_name [type_short_name] \
            -pretty_name [type_pretty_name] \
            -description [type_description]
    }
}

ad_proc -private simulation::notification::xml_map::unregister {} {
    db_transaction {
        notification::type::delete -short_name [type_short_name]

        acs_sc::impl::delete \
            -contract_name "NotificationType" \
            -impl_name [sc_name]
    }
}

ad_proc -private simulation::notification::xml_map::sc_id {} {
    return [acs_sc::impl::get_id \
                -owner [simulation::package_key] \
                -name [sc_name]]
}

ad_proc -private simulation::notification::xml_map::sc_name {} {
    return "MapXMLNotification"
}

ad_proc -private simulation::notification::xml_map::type_short_name {} {
    return "map_xml"
}

ad_proc -private simulation::notification::xml_map::type_pretty_name {} {
    return "Map XML"
}

ad_proc -private simulation::notification::xml_map::type_description {} {
    return "Notification of changes to the Map XML file."
}

ad_proc -public simulation::notification::xml_map::get_url {
    object_id
} {
    # This proc is not needed
}

ad_proc -public simulation::notification::xml_map::process_reply {
    reply_id
} {
    # This proc is not needed
}    

###############################
#
# simulation::notification::message namespace
# 
###############################

ad_proc -private simulation::notification::message::register {} {
    db_transaction {
        set spec [list \
                      contract_name "NotificationType" \
                      name [sc_name] \
                      aliases {
                          GetURL       simulation::notification::message::get_url
                          ProcessReply simulation::notification::message::process_reply
                      } \
                      owner [simulation::package_key]]
        set sc_impl_id [acs_sc::impl::new_from_spec -spec $spec]

        notification::type::new \
            -all_intervals \
            -all_delivery_methods \
            -sc_impl_id $sc_impl_id \
            -short_name [type_short_name] \
            -pretty_name [type_pretty_name] \
            -description [type_description]
    }
}

ad_proc -private simulation::notification::message::unregister {} {
    db_transaction {
        notification::type::delete -short_name [type_short_name]

        acs_sc::impl::delete \
            -contract_name "NotificationType" \
            -impl_name [sc_name]
    }
}

ad_proc -private simulation::notification::message::sc_id {} {
    return [acs_sc::impl::get_id \
                -owner [simulation::package_key] \
                -name [sc_name]]
}

ad_proc -private simulation::notification::message::sc_name {} {
    return "SimplayMessageNotification"
}

ad_proc -private simulation::notification::message::type_short_name {} {
    return "simplay_message"
}

ad_proc -private simulation::notification::message::type_pretty_name {} {
    return "Simplay Message"
}

ad_proc -private simulation::notification::message::type_description {} {
    return "Notification of received SimPlay messages."
}

ad_proc -public simulation::notification::message::get_url {
    object_id
} {
    # This proc is not needed
}

ad_proc -public simulation::notification::message::process_reply {
    reply_id
} {
    # This proc is not needed
}    
