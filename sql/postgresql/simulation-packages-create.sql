-- @author joel@collaboraid.net
-- @creation-date 2003-10-12
-- @cvs-id $Id$

select define_function_args('sim_case__new','sim_case_id,label,package_id,object_type;sim_case,creation_user,creation_ip,context_id');

create function sim_case__new (integer,varchar,integer,varchar,integer,varchar,integer)
returns integer as '
declare
    p_sim_case_id                   alias for $1;
    p_label                         alias for $2;
    p_package_id                    alias for $3;
    p_object_type                   alias for $4;
    p_creation_user                 alias for $5;
    p_creation_ip                   alias for $6;
    p_context_id                    alias for $7;

    v_sim_case_id                   integer;
begin
    v_sim_case_id:= acs_object__new(
        p_sim_case_id,
        ''sim_case'',
        now(),
        p_creation_user,
        p_creation_ip,
        p_context_id
    );

    insert into sim_cases
        (sim_case_id, label , package_id) 
    values
        (v_sim_case_id, p_label, p_package_id);

    return v_sim_case_id;
end;
' language 'plpgsql';

select define_function_args('sim_case__name','sim_case_id');

create function sim_case__name(integer)
returns varchar as '
declare
    p_sim_case_id_id                      alias for $1;
begin
    return label from sim_cases where sim_case_id = p_sim_case_id;
end;
' language 'plpgsql';

select define_function_args('sim_case__delete','sim_case_id');

create function sim_case__delete(integer)
returns integer as '
declare
    p_sim_case_id                      alias for $1;
begin
    perform acs_object__delete(p_sim_case_id);
    return 0;
end;
' language 'plpgsql';
