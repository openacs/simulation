-- @author joel@collaboraid.net
-- @creation-date 2003-10-12
-- @cvs-id $Id$

--drop independent tables
drop table sim_messages_trash;
drop table sim_portfolio_trash;
drop table sim_party_sim_map;
drop table sim_task_recipients;
drop table sim_tasks;
drop table sim_role_party_map;
drop table sim_roles;
drop table sim_simulation_emails;
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
            perform content_folder__unregister_content_type(row.folder_id, ''sim_characters'',''t'');
        end loop;
    return 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0 ();
