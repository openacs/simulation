1-- create dummy users for permissions testing
-- create each user and then assign appropriate privs directly

-- this is a temp solution - should instead create all the groups 
-- and assign privs to groups as part of normal install, and then
-- put test users in appropriate groups

-- need package id!

-- WARNING - all of these users are dangerous until they are added to registered user (-2) with
-- group::add_member -group_id -2 -user_id user_id

create function inline_0 () returns integer as '
declare
  random_seed    int4;
  package_id     int4;
  user_id        int4;
begin
        -- hack in package_id
        package_id := 581; 

        -- set a random seed to avoid duplicate records
        random_seed := trunc(random() * 100000);

        -- create SimAdmin user and assign privs
        select acs_user__new(null,''user'',null,null,null,null,''sally'' || random_seed,''email'' || random_seed,null,''Sally'',''SimAdmin'',null,null,null,''t'',null) into user_id;
        perform acs_permission__grant_permission(package_id,user_id,''sim_admin'');

        -- create TemplateAuthor user and assign privs
        select acs_user__new(null,''user'',null,null,null,null,''tom'' || random_seed,''email1'' || random_seed,null,''Tom'',''TemplateAuthor'',null,null,null,''t'',null) into user_id;
        perform acs_permission__grant_permission(package_id,user_id,''sim_template_creator'');
        perform acs_permission__grant_permission(package_id,user_id,''sim_inst'');
        perform acs_permission__grant_permission(package_id,user_id,''sim_object_create'');

        -- create CaseAuthor user and assign privs
        select acs_user__new(null,''user'',null,null,null,null,''cassie'' || random_seed,''email2'' || random_seed,null,''Cassie'',''CaseAuthor'',null,null,null,''t'',null) into user_id;
        perform acs_permission__grant_permission(package_id,user_id,''sim_inst'');
        perform acs_permission__grant_permission(package_id,user_id,''sim_object_create'');

        -- create ServiceAdmin user and assign privs
        select acs_user__new(null,''user'',null,null,null,null,''sergei'' || random_seed,''email3'' || random_seed,null,''Sergei'',''ServiceAdmin'',null,null,null,''t'',null) into user_id;
        -- power to create openacs users

        -- create CityAdmin user and assign privs
        select acs_user__new(null,''user'',null,null,null,null,''cindy'' || random_seed,''email4'' || random_seed,null,''Cindy'',''CityAdmin'',null,null,null,''t'',null) into user_id;
        perform acs_permission__grant_permission(package_id,user_id,''sim_set_map_p'');
        perform acs_permission__grant_permission(package_id,user_id,''sim_object_writer'');

        -- create Actor user and assign privs
        select acs_user__new(null,''user'',null,null,null,null,''alice'' || random_seed,''email5'' || random_seed,null,''Alice'',''Actor'',null,null,null,''t'',null) into user_id;

        return 0;
end;' language 'plpgsql';
select inline_0();
drop function inline_0 ();

