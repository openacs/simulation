
# case_id: either passed as a property, or in the URL

if { ![exists_and_not_null case_id] } {
    set case_id [ns_queryget case_id]
}

if { ![exists_and_not_null role_id] } {
    set role_id [ns_queryget role_id]
}

# Get any simulation specific Stylesheet
# 
set stylesheet_link ""
set stylesheet_name [db_string select_stylesheet {
    select ci.name
    from sim_simulations ss,
         cr_items ci
    where ss.stylesheet = ci.item_id
      and ss.simulation_id = (select workflow_id
                              from workflow_cases
                              where case_id = :case_id)
} -default {}]
if { ![empty_string_p $stylesheet_name] } {
    set stylesheet_url [simulation::object::content_url -name $stylesheet_name]
    set stylesheet_link "<link rel=\"stylesheet\" type=\"text/css\" href=\"$stylesheet_url\" media=\"all\">"
}

if { [template::util::is_nil header_stuff] } {
    set header_stuff ""
}

append header_stuff "\n$stylesheet_link"