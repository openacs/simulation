-- @author Lars Pind (lars@collaboraid.biz)
-- @creation-date 2003-10-14
-- @cvs-id $Id$

----------------------------------------------------------------------
-- drop everything in reverse order of creation
----------------------------------------------------------------------
-- have to manually drop attributes because content_type__drop_type doesn't
-- bad, stupid content_type__drop_type

----------------------------------------------------------------------
-- sim_case
----------------------------------------------------------------------

select content_type__drop_type(
    'sim_case',
    't',
    't'
);

----------------------------------------------------------------------
-- sim_location
----------------------------------------------------------------------

select content_type__unregister_relation_type (
    'sim_location',                -- content_type
    'sim_location',                -- target_type
    'is_located_in'                -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_location',                -- content_type
    'image',                       -- target_type
    'thumbnail'                    -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_location',                -- content_type
    'sim_stylesheet',              -- target_type
    'stylesheet'                   -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_location',                -- content_type
    'image',                       -- target_type
    'image'                        -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_location',                -- content_type
    'image',                       -- target_type
    'letterhead'                   -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_location',                -- content_type
    'image',                       -- target_type
    'logo'                         -- relation_tag
);

select content_type__drop_type(
    'sim_location',
    't',
    't'
);


----------------------------------------------------------------------
-- sim_message
----------------------------------------------------------------------

select content_type__unregister_relation_type (
    'sim_message',                 -- content_type
    'sim_prop',                    -- target_type
    'attachment'                   -- relation_tag
);

select content_type__drop_type(
    'sim_message',
    't',
    't'
);



----------------------------------------------------------------------
-- sim_prop
----------------------------------------------------------------------

select content_type__unregister_relation_type (
    'sim_prop',                    -- content_type
    'image',                       -- target_type
    'thumbnail'                    -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_prop',                    -- content_type
    'sim_stylesheet',              -- target_type
    'stylesheet'                   -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_prop',                    -- content_type
    'image',                       -- target_type
    'image'                        -- relation_tag
);

select content_type__drop_type(
    'sim_prop',
    't',
    't'
);


----------------------------------------------------------------------
-- sim_character
----------------------------------------------------------------------

select content_type__unregister_relation_type (
    'sim_character',               -- content_type
    'sim_location',                -- target_type
    'resides_at'                   -- relation_tag
);


select content_type__unregister_relation_type (
    'sim_character',               -- content_type
    'sim_location',                -- target_type
    'works_for'                    -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_character',               -- content_type
    'image',                       -- target_type
    'thumbnail'                    -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_character',               -- content_type
    'sim_stylesheet',              -- target_type
    'stylesheet'                   -- relation_tag
);

select content_type__unregister_relation_type (
    'sim_character',               -- content_type
    'image',                       -- target_type
    'image'                        -- relation_tag
);

select content_type__drop_type(
    'sim_character',
    't',
    't'
);

----------------------------------------------------------------------
-- sim_stylesheet
----------------------------------------------------------------------

select content_type__drop_type(
    'sim_stylesheet',
    't',
    't'

);
