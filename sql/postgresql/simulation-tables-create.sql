-- @author joel@collaboraid.net
-- @creation-date 2003-10-12
-- @cvs-id $Id$

create table sim_simulations (
    simulation_id         integer       constraint sim_simulations_fk
                                        references workflows
                                        on delete cascade
                                        constraint sim_simulation_pk
                                        primary key,
    suggested_duration    interval,
    sim_type              varchar(20)   constraint sim_simulations_type_ck
                                          check (sim_type in ('dev_template','ready_template','dev_sim','casting_sim','live_sim')),
    enroll_type           varchar(20)   constraint sim_simulations_enroll_type_ck
                                        check (enroll_type in ('closed','open')),
    casting_type          varchar(20)   constraint sim_simulations_casting_type_ck
                                        check (casting_type in ('auto','group','open')),
    enroll_start          timestamptz,
    enroll_end            timestamptz,
    constraint sim_simulations_enroll_end_after_start_end_ck
      check (enroll_end >= enroll_start),
    case_start            timestamptz,
    case_end              timestamptz,
    send_start_note_date  timestamptz,
    constraint sim_simulations_case_end_after_start_ck
      check (case_end >= case_start)
);

select acs_object_type__create_type (
        'simulation',                           -- object_type
        'Simulation',                           -- pretty_name
        'Simulations',                          -- pretty_plural
        'workflow_lite',                        -- supertype
        'sim_simulations',                      -- table_name
        'simulation_id',                        -- id_column
        null,                                   -- package_name
        'f',                                    -- abstract_p
        null,                                   -- type_extension_table
        'sim_simulation__name'                  -- name_method
        );
        
comment on table sim_simulations is 'Each record is an instantiation of a simulation template, and the parent of zero to many simulation cases.';

create table sim_roles (
    role_id             integer         constraint sim_roles_ri_fk
                                        references workflow_roles(role_id)
                                        on delete cascade
                                        constraint sim_roles_pk
                                        primary key,
    character_id        integer         constraint sim_roles_character_fk
                                        references cr_items
                                        on delete cascade,
    users_per_case      integer         default 1
);

comment on table sim_roles is 'Each record is a role within a simulation template to be played by one or more users or a computer agent when the template is instantiated into cases.';
  
create table sim_role_party_map (
    role_id             integer         constraint sim_role_party_map_ri_fk
                                        references workflow_roles(role_id)
                                        on delete cascade,
    party_id            integer         constraint sim_role_party_map_party_fk
                                        references parties
                                        on delete cascade,
    constraint sim_role_party_map_pk
    primary key(role_id, party_id)
);

comment on table sim_role_party_map is 'Each record defines a group of users to be cast into a role in groups of group_size';

create table sim_tasks (
    task_id             integer         constraint sim_tasks_fk
                                        references workflow_actions
                                        on delete cascade
                                        constraint sim_tasks_pk
                                        primary key,
    recipient           integer         constraint sim_tasks_recipient_fk
                                        references workflow_roles
                                        on delete cascade,
    attachment_num      integer         default 0
);

comment on table sim_tasks is 'A 1-1 extension of workflow_actions.  Each record is a task that a role must perform, possibly upon another role.';

create table sim_task_object_map (
    task_id             integer         constraint stom_fk
                                        references workflow_actions
                                        on delete cascade,
    object_id           integer         constraint stom_object_fk
                                        references acs_objects
                                        on delete cascade,
    relation_tag        varchar(100),
    order_n             integer,
    constraint stom_pk
      primary key (task_id, object_id, relation_tag, order_n)
);

comment on table sim_task_object_map is 'A mapping table to show which tasks use which props.  Each record is one prop for one task.';

create table sim_party_sim_map (
    simulation_id       integer         constraint sim_party_sim_map_sim_fk
                                        references sim_simulations
                                        on delete cascade,
    party_id            integer         constraint sim_party_sim_map_party_fk
                                        references parties
                                        on delete cascade,
    type                varchar(20)     constraint sim_party_sim_map_type_ck
                                        check (type in ('enrolled', 'invited', 'auto-enroll')),    
    constraint sim_party_sim_map_pk
    primary key (simulation_id, party_id)
);

comment on table sim_party_sim_map is 'Each record is an invitation to a party to participate in a simulation.';

create table sim_case_task_object_map (
    task_id             integer         constraint sctom_fk
                                        references workflow_actions
                                        on delete cascade,
    object_id           integer         constraint sctom_object_fk
                                        references acs_objects
                                        on delete cascade,
    case_id             integer         constraint sctom_case_fk
                                        references workflow_cases
                                        on delete cascade,
    order_n             integer,
    relation_tag        varchar(100),
    constraint sctom_pk
      primary key (task_id, object_id, case_id, relation_tag)
);

comment on table sim_case_task_object_map is 'A mapping table to show which tasks use which props in a case.  Each record is one prop for one task, in a case.';

create table sim_case_role_object_map (
    role_id             integer         constraint scrom_fk
                                        references workflow_roles
                                        on delete cascade,
    object_id           integer         constraint scrom_object_fk
                                        references acs_objects
                                        on delete cascade,
    case_id             integer         constraint scrom_case_fk
                                        references workflow_cases
                                        on delete cascade,
    order_n             integer,
    relation_tag        varchar(100),
    constraint scrom_pk
      primary key (role_id, object_id, case_id, relation_tag)
);

comment on table sim_case_role_object_map is 'The portfolio of sim_props for a role in a case.';


----------------------------------------------------------------------
-- sim_case
----------------------------------------------------------------------

select acs_object_type__create_type (
    'sim_case',                             -- object_type
    'Simulation Case',                      -- pretty_name
    'Simulation Cases',                     -- pretty_plural
    'acs_object',                           -- supertype
    'sim_cases',                            -- table_name
    'sim_case_id'  ,                        -- id_column
    null,                                   -- package_name
    'f',                                    -- abstract_p
    null,                                   -- type_extension_table
    'acs_object__name'                      -- name_method
);
      
create table sim_cases (
    sim_case_id         integer         constraint sim_case_fk
                                        references acs_objects
                                        constraint sim_case_pk
                                        primary key,
    workflow_id         integer         constraint sim_case_workflow_fk
                                        references workflows,
    sort_order          integer,
    constraint sim_case_workflow_sort_order_un unique (workflow_id, sort_order)
);

comment on table sim_cases is 'The object behind a simulation case.';

