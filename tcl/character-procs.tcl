ad_library {
    API for Simulation characters.

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-10-14
    @cvs-id $Id$
}

namespace eval simulation::character {}

ad_proc -public simulation::character::get {
    {-character_id:required}
    {-array:required}
} {
    Get basic information about a character. Gets the following attributes: uri, title.

    @param  array       The name of an array into which you want the information put. 

    @author Peter Marklund
} {
    upvar $array row

    db_1row select_character_info {} -column_array row
}

ad_proc -public simulation::character::get_element {
    {-character_id:required}
    {-element:required}
} {
    Get a particular attribute from a character object.

    @param element Name of the attribute you want to retrieve

    @see simulation::character::get

    @author Peter Marklund
} {
    get -character_id $character_id -array character

    return $character($element)
}
