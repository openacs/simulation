-- @author joel@collaboraid.net
-- @creation-date 2003-10-12
-- @cvs-id $Id$


select drop_package('sim_object');

delete from acs_permissions 
      where object_id in (select simobject_id from sim_object);

--drop objects
--declare
--	object_rec		record;
--begin
--	for object_rec in select object_id from acs_objects where object_type=''simobject''
--	loop
--		perform acs_object__delete( object_rec.object_id );
--	end loop;
--	return 0;
--end;' language 'plpgsql';

--drop tables
drop table sim_taskresult;
drop table sim_case;
drop table sim_task;
drop table sim_role;
drop table sim_object_in_template;
drop table sim_party_in_sim;
drop table sim_simulation;
drop table sim_template;
drop table sim_object;


--drop types
select acs_object_type__drop_type(
	   'simobject',
	   't'
    );

select acs_object_type__drop_type(
	   'simtemplate',
	   't'
    );

select acs_object_type__drop_type(
	   'simsimulation',
	   't'
    );

