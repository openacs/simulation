-- set up privileges and hierarchy, top-down
-- syntax is select acs_privilege__add_child(parent, child)

select acs_privilege__create_privilege('sim_admin','Administer Simulation Package',null);
select acs_privilege__add_child('admin','sim_admin');

select acs_privilege__create_privilege('sim_inst','Instantiate Simulation Templates into Simulations',null);
select acs_privilege__add_child('sim_admin','sim_inst');

select acs_privilege__create_privilege('sim_object_create','Can create simulation objects.',null);
select acs_privilege__create_privilege('sim_object_write','Can edit other people\'s simulation objects',null);
select acs_privilege__create_privilege('sim_object_writer','Has write and create privs',null);
-- writer includes both create and write
select acs_privilege__add_child('sim_object_writer','sim_object_create');
select acs_privilege__add_child('sim_object_writer','sim_object_write');
select acs_privilege__add_child('sim_admin','sim_object_writer');

select acs_privilege__create_privilege('sim_set_map_p','Can toggle whether or not sim objects are shown on the map',null);
select acs_privilege__add_child('sim_admin','sim_set_map_p');

select acs_privilege__create_privilege('sim_template_read','Read Simulation Templates',null);
select acs_privilege__create_privilege('sim_template_create','Create Simulation Templates',null);
select acs_privilege__create_privilege('sim_template_creator','Create and Read Simulation Templates',null);
select acs_privilege__add_child('sim_template_creator','sim_template_create');
select acs_privilege__add_child('sim_template_creator','sim_template_read');
select acs_privilege__add_child('sim_admin','sim_template_creator');


