-- privileges
select acs_privilege__create_privilege('sim_admin','Simulation Admin',null);

-- add children
select acs_privilege__add_child('sim_admin','sim_template_create');
select acs_privilege__add_child('sim_admin','sim_inst');
select acs_privilege__add_child('sim_admin','sim_object_create');
select acs_privilege__add_child('sim_admin','sim_object_write');
select acs_privilege__add_child('sim_admin','sim_set_map_p');
