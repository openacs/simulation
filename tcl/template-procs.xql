<?xml version="1.0"?>
<queryset>

  <fullquery name="simulation::template::get.select_template">
        <querytext>
          select w.workflow_id,
                 w.short_name,
                 w.pretty_name, 
                 w.object_id, 
                 w.package_key, 
                 w.object_type, 
                 w.description,
                 s.suggested_duration,
                 s.sim_type,
                 s.enroll_type,
                 s.casting_type,
                 to_char(s.enroll_start, 'YYYY-MM-DD'),
                 to_char(s.enroll_end, 'YYYY-MM-DD'),
                 to_char(s.case_start, 'YYYY-MM-DD'),
                 to_char(s.case_end, 'YYYY-MM-DD'),
                 to_char(s.send_start_note_date, 'YYYY-MM-DD')
          from workflows w,
               sim_simulations s
          where w.workflow_id = :workflow_id
            and w.workflow_id = s.simulation_id
        </querytext>
  </fullquery>

</queryset>
