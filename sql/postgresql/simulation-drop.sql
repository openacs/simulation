-- @author joel@collaboraid.net
-- @creation-date 2003-10-12
-- @cvs-id $Id$


select drop_package('sim_object');

delete from acs_permissions 
      where object_id in (select sim_object_id from sim_objects);

--drop objects
--declare
--	object_rec		record;
--begin
--	for object_rec in select object_id from acs_objects where object_type=''sim_object''
--	loop
--		perform acs_object__delete( object_rec.object_id );
--	end loop;
--	return 0;
--end;' language 'plpgsql';

--drop tables
drop table sim_party_sim_map;
drop table sim_simulations;
drop table sim_tasks;
drop table sim_roles;
drop table sim_workflow_object_map;
drop table sim_objects;


--drop types
select acs_object_type__drop_type(
	   'sim_object',
	   't'
    );

select acs_object_type__drop_type(
	   'simulation',
	   't'
    );

