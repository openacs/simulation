-- add column sim_party_sim_map.multiple_cases_p

alter table sim_party_sim_map add
    multiple_cases_p boolean;

alter table sim_party_sim_map
  alter column multiple_cases_p
    set default 'f';

update sim_party_sim_map
  set multiple_cases_p = 'f'
where multiple_cases_p is null;

-- Add column sim_simulations.stylesheet
alter table sim_simulations add 
        stylesheet                          integer
                                            constraint sim_simulations_ss_fk
                                            references cr_items(item_id);
