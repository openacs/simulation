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
    enroll_start                        timestamptz,
    enroll_end                          timestamptz,
    constraint sim_simulations_enroll_end_after_start_end_ck
      check (enroll_end >= enroll_start),
    case_start                          timestamptz,
    case_end                            timestamptz,
    send_start_note_date                timestamptz,
    constraint sim_simulations_case_end_after_start_ck
      check (case_end >= case_start),
    show_contacts_p                     boolean default 't'
    constraint sim_show_contacts_p_ck
      check(show_contacts_p in ('t','f'))
    constraint sim_show_contacts_p_nn
      not null,
    show_states_p                       boolean default 't'
    constraint sim_show_states_p_ck
      check(show_states_p in ('t','f'))
    constraint sim_show_states_p_nn
      not null,
    stylesheet                          integer
                                        constraint sim_simulations_ss_fk
                                        references cr_items(item_id)                                        
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

create table sim_simulation_emails (
    simulation_id         integer       constraint sim_simulation_emails_sid_fk
                                        references workflows
                                        on delete cascade,
    user_id               integer       constraint sim_simulation_emails_uid_fk
                                        references users(user_id),
    email_type            varchar(20)   constraint sim_simulation_emails_et_ck
                                        check (email_type in ('reminder')),
    send_date             timestamptz
);

comment on table sim_simulation_emails is 'Keeps track of notifications sent to users for a certain simulation.';      

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

comment on table sim_role_party_map is 'Each record defines a group of users to be cast into a role';

create table sim_tasks (
    task_id             integer         constraint sim_tasks_fk
                                        references workflow_actions
                                        on delete cascade
                                        constraint sim_tasks_pk
                                        primary key,
    attachment_num      integer         default 0
);

comment on table sim_tasks is 'A 1-1 extension of workflow_actions.  Each record is a task that a role must perform, possibly upon another role.';

create table sim_task_recipients (
        task_id         integer         constraint sim_task_recipients_tid_fk
                                        references sim_tasks(task_id)
                                        on delete cascade,
        recipient       integer         constraint sim_task_recipients_rid_fk
                                        references workflow_roles(role_id)
                                        on delete cascade,
        constraint sim_task_recipients_pk
        primary key(task_id, recipient)
);

comment on table sim_task_recipients is 'Each record is a recipient for a task. This table allows each task to have 0 or more recipients';

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
                                        check (type in ('enrolled', 'invited', 'auto_enroll')),
    multiple_cases_p    boolean         constraint sim_party_sim_map_mcp_nn
                                        not null
                                        default 'f',
    constraint sim_party_sim_map_pk
    primary key (simulation_id, party_id, type)
);

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
    entry_id            integer         constraint scrom_case_log_fk
                                        references workflow_case_log,
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
    'sim_case',                             -- package_name
    'f',                                    -- abstract_p
    null,                                   -- type_extension_table
    'sim_case__name'                        -- name_method
);
      
create table sim_cases (
    sim_case_id         integer         constraint sim_case_sci_fk
                                        references acs_objects
                                        on delete cascade
                                        constraint sim_case_pk
                                        primary key,
    label               varchar(200),
    package_id          integer         constraint sim_case_pid_fk
                                        references apm_packages(package_id)
                                        constraint sim_case_pid_nn
                                        not null
);

comment on table sim_cases is 'The object behind a simulation case.';

