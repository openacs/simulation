-- @author Lars Pind (lars@collaboraid.biz)
-- @creation-date 2003-10-14
-- @cvs-id $Id$


-- sim_character

select content_type__create_type(
    'sim_character',               -- content_type
    'content_revision',            -- supertype
    'Character',                   -- pretty_name,
    'Characters',                  -- pretty_plural
    'sim_characters',              -- table_name
    'character_id',                -- id_column
    null                           -- name_method
);




-- sim_prop

select content_type__create_type(
    'sim_prop',                    -- content_type
    'content_revision',            -- supertype
    'Prop',                        -- pretty_name,
    'Props',                       -- pretty_plural
    'sim_props',                   -- table_name
    'prop_id',                     -- id_column
    null                           -- name_method
);



-- sim_home

select content_type__create_type(
    'sim_home',                    -- content_type
    'content_revision',            -- supertype
    'Home',                        -- pretty_name,
    'Homes',                       -- pretty_plural
    'sim_homes',                   -- table_name
    'home_id',                     -- id_column
    null                           -- name_method
);

select content_type__create_attribute(
    'sim_home',                    -- content_type
    'address',                     -- attribute_name
    'string',                      -- datatype
    'Addresss',                    -- pretty_name
    'Addresses',                   -- pretty_plural
    1,                             -- sort_order
    null,                          -- default_value
    'varchar(4000)'                -- column_spec
);

select content_type__create_attribute(
    'sim_home',                    -- content_type
    'city',                        -- attribute_name
    'string',                      -- datatype
    'City',                        -- pretty_name
    'Cities',                      -- pretty_plural
    2,                             -- sort_order
    null,                          -- default_value
    'varchar(4000)'                -- column_spec
);

select content_type__create_attribute(
    'sim_home',                    -- content_type
    'history',                     -- attribute_name
    'text',                        -- datatype
    'History',                     -- pretty_name
    'Histories',                   -- pretty_plural
    3,                             -- sort_order
    null,                          -- default_value
    'text'                         -- column_spec
);

select content_type__create_attribute(
    'sim_home',                    -- content_type
    'stylesheet',                  -- attribute_name
    'text',                        -- datatype
    'Stylesheet',                  -- pretty_name
    'Stylesheets',                 -- pretty_plural
    5,                             -- sort_order
    null,                          -- default_value
    'text'                         -- column_spec
);






