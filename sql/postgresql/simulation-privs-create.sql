-- privileges
select acs_privilege__add_child('admin','sim_admin');
select acs_privilege__add_child('sim_admin','sim_template_create');
select acs_privilege__add_child('sim_admin','sim_inst');
select acs_privilege__add_child('sim_admin','sim_set_map_p');
select acs_privilege__add_child('sim_admin','sim_object_writer');
select acs_privilege__add_child('sim_object_writer','sim_object_create');
select acs_privilege__add_child('sim_object_writer','sim_object_write');
