-- @author Lars Pind (lars@collaboraid.biz)
-- @creation-date 2003-10-14
-- @cvs-id $Id$

----------------------------------------------------------------------
-- sim_stylesheet
----------------------------------------------------------------------

select content_type__create_type(
    'sim_stylesheet',              -- content_type
    'content_revision',            -- supertype
    'Stylesheet',                  -- pretty_name,
    'Stylesheets',                 -- pretty_plural
    'sim_stylesheets',             -- table_name
    'stylesheet_id',                     -- id_column
    null                           -- name_method
);


----------------------------------------------------------------------
-- sim_location
----------------------------------------------------------------------

select content_type__create_type(
    'sim_location',                -- content_type
    'content_revision',            -- supertype
    'Location',                    -- pretty_name,
    'Locations',                   -- pretty_plural
    'sim_locations',               -- table_name
    'location_id',                 -- id_column
    null                           -- name_method
);

select content_type__create_attribute(
    'sim_location',                -- content_type
    'on_map_p',                    -- attribute_name
    'boolean',                     -- datatype
    'Show on map',                 -- pretty_name
    'Show on map',                 -- pretty_plural
    1,                             -- sort_order
    'f',                           -- default_value
    'boolean'                      -- column_spec
);

select content_type__create_attribute(
    'sim_location',                -- content_type
    'in_directory_p',              -- attribute_name
    'boolean',                     -- datatype
    'Show in directory',           -- pretty_name
    'Show in directory',           -- pretty_plural
    2,                             -- sort_order
    'f',                           -- default_value
    'boolean'                      -- column_spec
);

select content_type__create_attribute(
    'sim_location',                -- content_type
    'address',                     -- attribute_name
    'string',                      -- datatype
    'Addresss',                    -- pretty_name
    'Addresses',                   -- pretty_plural
    3,                             -- sort_order
    null,                          -- default_value
    'varchar(4000)'                -- column_spec
);

select content_type__create_attribute(
    'sim_location',                -- content_type
    'city',                        -- attribute_name
    'string',                      -- datatype
    'City',                        -- pretty_name
    'Cities',                      -- pretty_plural
    4,                             -- sort_order
    null,                          -- default_value
    'varchar(4000)'                -- column_spec
);

select content_type__create_attribute(
    'sim_location',                -- content_type
    'history',                     -- attribute_name
    'text',                        -- datatype
    'History',                     -- pretty_name
    'Histories',                   -- pretty_plural
    5,                             -- sort_order
    null,                          -- default_value
    'text'                         -- column_spec
);

select content_type__register_relation_type (
    'sim_location',                -- content_type
    'image',                       -- target_type
    'thumbnail',                   -- relation_tag
    1,                             -- min_n
    1                              -- max_n
);

select content_type__register_relation_type (
    'sim_location',                -- content_type
    'sim_stylesheet',              -- target_type
    'stylesheet',                  -- relation_tag
    1,                             -- min_n
    1                              -- max_n
);

select content_type__register_relation_type (
    'sim_location',                -- content_type
    'image',                       -- target_type
    'image',                       -- relation_tag
    0,                             -- min_n
    10                             -- max_n
);

select content_type__register_relation_type (
    'sim_location',                -- content_type
    'image',                       -- target_type
    'letterhead',                  -- relation_tag
    1,                             -- min_n
    1                              -- max_n
);

select content_type__register_relation_type (
    'sim_location',                -- content_type
    'image',                       -- target_type
    'logo',                        -- relation_tag
    1,                             -- min_n
    1                              -- max_n
);

select content_type__register_relation_type (
    'sim_location',                -- content_type
    'sim_location',                -- target_type
    'is_located_in',               -- relation_tag
    1,                             -- min_n
    1                              -- max_n
);


----------------------------------------------------------------------
-- sim_character
----------------------------------------------------------------------

select content_type__create_type(
    'sim_character',               -- content_type
    'content_revision',            -- supertype
    'Character',                   -- pretty_name,
    'Characters',                  -- pretty_plural
    'sim_characters',              -- table_name
    'character_id',                -- id_column
    null                           -- name_method
);

select content_type__create_attribute(
    'sim_character',               -- content_type
    'in_directory_p',              -- attribute_name
    'boolean',                     -- datatype
    'Show in directory',           -- pretty_name
    'Show in directory',           -- pretty_plural
    1,                             -- sort_order
    'f',                           -- default_value
    'boolean'                      -- column_spec
);

select content_type__register_relation_type (
    'sim_character',               -- content_type
    'image',                       -- target_type
    'thumbnail',                   -- relation_tag
    1,                             -- min_n
    1                              -- max_n
);

select content_type__register_relation_type (
    'sim_character',               -- content_type
    'sim_stylesheet',              -- target_type
    'stylesheet',                  -- relation_tag
    1,                             -- min_n
    1                              -- max_n
);

select content_type__register_relation_type (
    'sim_character',               -- content_type
    'image',                       -- target_type
    'image',                       -- relation_tag
    0,                             -- min_n
    10                             -- max_n
);

select content_type__register_relation_type (
    'sim_character',               -- content_type
    'sim_location',                -- target_type
    'works_for',                   -- relation_tag
    1,                             -- min_n
    1                              -- max_n
);

select content_type__register_relation_type (
    'sim_character',               -- content_type
    'sim_location',                -- target_type
    'resides_at',                  -- relation_tag
    1,                             -- min_n
    1                              -- max_n
);

----------------------------------------------------------------------
-- sim_prop
----------------------------------------------------------------------

select content_type__create_type(
    'sim_prop',                    -- content_type
    'content_revision',            -- supertype
    'Prop',                        -- pretty_name,
    'Props',                       -- pretty_plural
    'sim_props',                   -- table_name
    'prop_id',                     -- id_column
    null                           -- name_method
);

select content_type__create_attribute(
    'sim_prop',                    -- content_type
    'on_map_p',                    -- attribute_name
    'boolean',                     -- datatype
    'Show on map',                 -- pretty_name
    'Show on map',                 -- pretty_plural
    1,                             -- sort_order
    'f',                           -- default_value
    'boolean'                      -- column_spec
);

select content_type__register_relation_type (
    'sim_prop',                    -- content_type
    'image',                       -- target_type
    'thumbnail',                   -- relation_tag
    1,                             -- min_n
    1                              -- max_n
);

select content_type__register_relation_type (
    'sim_prop',                    -- content_type
    'sim_stylesheet',              -- target_type
    'stylesheet',                  -- relation_tag
    1,                             -- min_n
    1                              -- max_n
);

select content_type__register_relation_type (
    'sim_prop',                    -- content_type
    'image',                       -- target_type
    'image',                       -- relation_tag
    0,                             -- min_n
    10                             -- max_n
);

select content_type__register_relation_type (
    'sim_prop',                    -- content_type
    'sim_location',                -- target_type
    'associated',                  -- relation_tag
    0,                             -- min_n
    1                              -- max_n
);


----------------------------------------------------------------------
-- sim_message
----------------------------------------------------------------------
-- # TODO: foreign constraints for to_role_id and from_role_id

select content_type__create_type(
    'sim_message',                 -- content_type
    'content_revision',            -- supertype
    'Sim Message',                 -- pretty_name,
    'Sim Messages',                -- pretty_plural
    'sim_messages',                -- table_name
    'message_id',                  -- id_column
    null                           -- name_method
);

select content_type__create_attribute(
    'sim_message',                 -- content_type
    'to_role_id',                  -- attribute_name
    'integer',                     -- datatype
    'To role_id',                  -- pretty_name
    'To role_ids',                 -- pretty_plural
    1,                             -- sort_order
    null,                          -- default_value
    'integer'                      -- column_spec
);

select content_type__create_attribute(
    'sim_message',                 -- content_type
    'from_role_id',                -- attribute_name
    'integer',                     -- datatype
    'From role_id',                -- pretty_name
    'From role_ids',               -- pretty_plural
    2,                             -- sort_order
    null,                          -- default_value
    'integer'                      -- column_spec
);

select content_type__create_attribute(
    'sim_message',                 -- content_type
    'case_id',                     -- attribute_name
    'integer',                     -- datatype
    'Case ID',                     -- pretty_name
    'Case IDs',                    -- pretty_plural
    3,                             -- sort_order
    null,                          -- default_value
    'integer'                      -- column_spec
);

select content_type__register_relation_type (
    'sim_message',                -- content_type
    'sim_prop',                   -- target_type
    'attachment',                  -- relation_tag
    0,                            -- min_n
    10                            -- max_n
);

