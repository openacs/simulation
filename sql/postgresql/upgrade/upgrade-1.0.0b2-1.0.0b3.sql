alter table sim_simulations add
    show_states_p       boolean
      constraint sim_show_states_p_ck
        check(show_states_p in ('t','f'))
;

alter table sim_simulations
  alter column show_states_p
    set default 't'
;

update sim_simulations
  set show_states_p = 't'
where show_states_p is null
;
