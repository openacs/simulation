-- privileges

select acs_privilege__create_privilege('sim_template_create','Can create and edit sim templates',null);
select acs_privilege__create_privilege('sim_inst','Can instantiate a sim template into a simulation and edit the simulation',null);
select acs_privilege__create_privilege('sim_object_create','Can create global sim objects',null);
select acs_privilege__create_privilege('sim_object_write','Can change other people''s sim objects',null);
select acs_privilege__create_privilege('sim_set_map_p','Can set and un-set on_map_p for any sim object',null);
