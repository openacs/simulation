-- @author joel@collaboraid.net
-- @creation-date 2003-10-12
-- @cvs-id $Id$


select drop_package('sim_object');

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

--drop independent tables
drop table sim_party_sim_map;
drop table sim_simulations;
drop table sim_tasks;
drop table sim_roles;
drop table sim_workflow_object_map;

--drop types
select acs_object_type__drop_type(
	   'sim_object',
	   't'
    );

select acs_object_type__drop_type(
	   'simulation',
	   't'
    );

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

-- drop content_types
create function inline_0 () returns integer as '
declare
    row record;
begin
    for row in select folder_id 
                  from cr_folders 
                 where package_id in (select package_id 
                                        from apm_packages 
                                       where package_key = ''simulation'') loop
            perform content_folder__unregister_content_type(v_id, ''sim_characters'',''t'');
        end loop;
    return 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0 ();



----------------------------------------------------------------------
-- drop everything in reverse order of creation
----------------------------------------------------------------------
-- have to manually drop attributes because content_type__drop_type doesn't
-- bad, stupid content_type__drop_type

----------------------------------------------------------------------
-- sim_location
----------------------------------------------------------------------

select content_type__unregister_relation_type (
    'sim_location',                -- content_type
    'image',                       -- target_type
    'thumbnail'                    -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_location',                -- content_type
    'sim_stylesheet',              -- target_type
    'stylesheet'                   -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_location',                -- content_type
    'image',                       -- target_type
    'image'                        -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_location',                -- content_type
    'image',                       -- target_type
    'letterhead'                   -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_location',                -- content_type
    'image',                       -- target_type
    'logo'                         -- relation_tag
);

select content_type__drop_type(
    'sim_location',
    't',
    't'
);


----------------------------------------------------------------------
-- sim_prop
----------------------------------------------------------------------

select content_type__unregister_relation_type (
    'sim_prop',                    -- content_type
    'image',                       -- target_type
    'thumbnail'                    -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_prop',                    -- content_type
    'sim_stylesheet',              -- target_type
    'stylesheet'                   -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_prop',                    -- content_type
    'image',                       -- target_type
    'image'                        -- relation_tag
);

select content_type__drop_type(
    'sim_prop',
    't',
    't'
);


----------------------------------------------------------------------
-- sim_character
----------------------------------------------------------------------

select content_type__unregister_relation_type (
    'sim_character',               -- content_type
    'image',                       -- target_type
    'thumbnail'                    -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_character',               -- content_type
    'sim_stylesheet',              -- target_type
    'stylesheet'                   -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_character',               -- content_type
    'image',                       -- target_type
    'image'                        -- relation_tag
);

select content_type__drop_type(
    'sim_character',
    't',
    't'
);

----------------------------------------------------------------------
-- sim_stylesheet
----------------------------------------------------------------------

select content_type__drop_type(
    'sim_stylesheet',
    't',
    't'

);


