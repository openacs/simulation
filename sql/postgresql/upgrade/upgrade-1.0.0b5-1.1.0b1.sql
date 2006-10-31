create table sim_trash (
  message_id            integer         constraint sim_trash_id_nn
                                        not null
                                        constraint sim_trash_id_fk
                                        references sim_messages,
  role_id               integer         constraint sim_trash_role_nn
                                        not null,
  case_id               integer         constraint sim_trash_case_nn
                                        not null,
  PRIMARY KEY (message_id, role_id, case_id)
);

comment on table sim_trash is 'For storing trashed messages per role per case.';
