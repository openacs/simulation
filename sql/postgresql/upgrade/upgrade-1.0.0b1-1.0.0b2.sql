alter table sim_simulations add
    show_contacts_p       boolean
      constraint sim_show_contacts_p_ck
        check(show_contacts_p in ('t','f'))
;

alter table sim_simulations
  alter column show_contacts_p
    set default 't'
;

update sim_simulations
  set show_contacts_p = 't'
where show_contacts_p is null
;
