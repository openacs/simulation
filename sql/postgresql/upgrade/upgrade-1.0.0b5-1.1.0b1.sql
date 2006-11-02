create table sim_messages_trash (
  message_id            integer         constraint sim_messages_trash_id_nn
                                        not null
                                        constraint sim_messages_trash_id_fk
                                        references sim_messages,
  role_id               integer         constraint sim_messages_trash_role_nn
                                        not null,
  case_id               integer         constraint sim_messages_trash_case_nn
                                        not null,
  PRIMARY KEY (message_id, role_id, case_id)
);

comment on table sim_messages_trash is 'For storing trashed messages per role per case.';

create table sim_portfolio_trash (
  object_id             integer         constraint sim_pt_id_nn
                                        not null
                                        constraint sim_pt_object_id_fk
                                        references acs_objects ON DELETE CASCADE,
  role_id               integer         constraint sim_pt_role_nn
                                        not null
                                        constraint sim_pt_role_fk
                                        REFERENCES workflow_roles ON DELETE CASCADE,
  case_id               integer         constraint sim_pt_case_nn
                                        not null
                                        constraint sim_pt_case_fk
                                        REFERENCES workflow_cases ON DELETE CASCADE,
  PRIMARY KEY (object_id, role_id, case_id)
);

comment on table sim_portfolio_trash is 'For storing trashed portfolio documents per role per case.';

alter table sim_case_role_object_map
  add column title varchar(200);