-- @author joel@collaboraid.net
-- @creation-date 2003-10-12
-- @cvs-id $Id$

--drop independent tables
drop table sim_party_sim_map;
drop table sim_tasks;
drop table sim_roles;
select acs_object_type__drop_type(
	   'simulation',
	   't'
    );
drop table sim_simulations;

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
    'sim_location',                -- target_type
    'is_located_in'                -- relation_tag
);

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
-- sim_message
----------------------------------------------------------------------

select content_type__unregister_relation_type (
    'sim_message',                 -- content_type
    'sim_prop',                    -- target_type
    'attachment'                   -- relation_tag
);

select content_type__drop_type(
    'sim_message',
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
    'sim_location',                -- target_type
    'resides_at'                   -- relation_tag
);


select content_type__unregister_relation_type (
    'sim_character',               -- content_type
    'sim_location',                -- target_type
    'works_for'                    -- relation_tag
);

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


----------------------------------------------------------------------
-- privileges
----------------------------------------------------------------------

create function inline_0 ()
returns integer as '
begin
    perform acs_privilege__remove_child(''sim_admin'',''sim_template_create'');
    perform acs_privilege__remove_child(''sim_admin'',''sim_inst'');
    perform acs_privilege__remove_child(''sim_admin'',''sim_object_writer'');
    perform acs_privilege__remove_child(''sim_admin'',''sim_set_map_p'');
    perform acs_privilege__remove_child(''sim_object_writer'',''sim_object_create'');
    perform acs_privilege__remove_child(''sim_object_writer'',''sim_object_write'');
    perform acs_privilege__remove_child(''admin'',''sim_admin'');

    return null;
end;' language 'plpgsql';

select inline_0();
drop function inline_0 ();
