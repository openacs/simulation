<?xml version="1.0"?>
<queryset>

  <fullquery name="simulation::character::get.select_character_info">
        <querytext>

            select ci.name as uri,
                   cr.title as title
            from cr_items ci,
                 cr_revisions cr
            where ci.live_revision = cr.revision_id
              and cr.item_id = :character_id   
        </querytext>
  </fullquery>

</queryset>
