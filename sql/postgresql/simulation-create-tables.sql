-- @author joel@collaboraid.net
-- @creation-date 2003-10-12
-- @cvs-id $Id$

create table sim_object (
    simobject_id	integer		constraint simobject_fk
					  references acs_objects
					constraint simobject_pk
					  primary key,
    parent_simobject    integer		constraint simobject_parent_fk
					  references sim_object,
    description		text
);

comment on table sim_object IS 'Each record is an object in a simulation package.';

select acs_object_type__create_type (
	'simobject',			        -- object_type
	'Simulation Object', 			-- pretty_name
	'Simulation Objects',			-- pretty_plural
	'acs_object',			        -- supertype
	'sim_object', 				-- table_name
	'simobject_id',      			-- id_column
	null,				        -- package_name
	'f',				        -- abstract_p
	null,				        -- type_extension_table
	'simobject__name' 			-- name_method
	);

create table sim_template (
    simtemplate_id	integer		constraint simtemplate_fk
					  references workflows
					constraint simtemplate_pk
					  primary key,
    duration		interval    
);

comment on table sim_template IS 'Each record is a template of a simulation.';

select acs_object_type__create_type (
	'simtemplate',			        -- template_type
	'Simulation Template', 			-- pretty_name
	'Simulation Templates',			-- pretty_plural
	'acs_object',			        -- supertype
	'sim_template', 				-- table_name
	'simtemplate_id',      			-- id_column
	null,				        -- package_name
	'f',				        -- abstract_p
	null,				        -- type_extension_table
	'simtemplate__name' 			-- name_method
	);

create table sim_simulation (
    simulation_id	integer		constraint sim_simulation_fk
					  references acs_objects
					constraint sim_simulation_pk
					  primary key,
    template_id		integer		constraint sim_sim_template_fk
					  references sim_template,
    enroll_type         varchar(20)	constraint sim_enroll_type_ck
                                          check (1=1),
    casting_type         varchar(20)	constraint sim_casting_type_ck
                                          check (1=1),
    enroll_start	timestamptz,
    enroll_end		timestamptz,
  					constraint sim_enroll_end_after_start_end_ck
 					  check (enroll_end >= enroll_start),
    case_start		timestamptz,
    case_end		timestamptz,
  					constraint sim_case_end_after_start_ck
 					  check (case_end >= case_start)
);

select acs_object_type__create_type (
	'simsimulation',			        -- simulation_type
	'Simulation Simulation', 			-- pretty_name
	'Simulation Simulations',			-- pretty_plural
	'acs_object',			        -- supertype
	'sim_simulation', 				-- table_name
	'simsimulation_id',      			-- id_column
	null,				        -- package_name
	'f',				        -- abstract_p
	null,				        -- type_extension_table
	'simsimulation__name' 			-- name_method
	);
	
comment on table sim_simulation is 'Each record is an instantiation of a simulation template, and the parent of zero to many simulation cases.';

create table sim_party_in_sim (
    simulation_id	integer		constraint sim_user_sim_fk
					  references sim_simulation,
    party_id		integer		constraint sim_user_party_fk
 					  references parties,
                                        constraint sim_party_in_sim_pk
    primary key (simulation_id, party_id)
);

comment on table sim_party_in_sim is 'Each record is an invitation to a party to participate in a simulation.';

create table sim_object_in_template (
    template_id		integer		constraint sim_object_templ_templ_fk
					  references sim_template,
    simobject_id	integer		constraint sim_object_templ_party_party_fk
 					  references sim_object,
                                        constraint sim_object_in_template_pk
    primary key (template_id, simobject_id)
);

comment on table sim_object_in_template is 'Each record indicates that one object is used in one simulation template.';

create table sim_role (
    role_id		integer		constraint sim_role_fk
					  references workflow_roles
					constraint sim_role_pk
					  primary key,
    character_id	integer		constraint sim_role_character_fk
                                          check (1=1)
);

comment on table sim_role is 'Each record is a role within a simulation template to be played by one or more users or a computer agent when the template is instantiated into cases.';

create table sim_task (
    task_id		integer		constraint sim_task_fk
					  references workflow_actions
					constraint sim_task_pk
					  primary key,
    recipient		integer		constraint sim_task_recipient_fk
					  references sim_role
);

comment on table sim_task is 'Each record is a task that a role must perform, possibly upon another role.';

create table sim_case (
    case_id		integer		constraint sim_case_fk
					  references workflow_cases
					constraint sim_case_pk
					  primary key,
    simulation_id	integer		constraint sim_case_simulation_fk
					  references sim_simulation
);

comment on table sim_case is 'Each record is a simulation case, derived from a simulation template via a simulation record.';

create table sim_taskresult (
    taskresult_id	integer		constraint sim_taskresult_fk
					  references workflow_cases
					constraint sim_taskresult_pk
					  primary key,
    completion_code	integer,
    completion_time     timestamptz,
    message		text
);
	
comment on table sim_taskresult is 'Each record shows the results of one task performed by one actor in one case.';




