-- @author joel@collaboraid.net
-- @creation-date 2003-10-12
-- @cvs-id $Id$

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

    perform acs_privilege__drop_privilege(''sim_object_write'');
    perform acs_privilege__drop_privilege(''sim_object_create'');
    perform acs_privilege__drop_privilege(''sim_object_writer'');
    perform acs_privilege__drop_privilege(''sim_set_map_p'');
    perform acs_privilege__drop_privilege(''sim_template_create'');
    perform acs_privilege__drop_privilege(''sim_inst'');
    perform acs_privilege__drop_privilege(''sim_admin'');
    return null;
end;' language 'plpgsql';

select inline_0();
drop function inline_0 ();
