
# case_id: either passed as a property, or in the URL

if { ![exists_and_not_null case_id] } {
    set case_id [ns_queryget case_id]
}