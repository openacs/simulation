ad_page_contract {
    The index page for SimInst
}

set page_title "Simulations in Development"
set context [list $page_title]
set package_id [ad_conn package_id]

set add_url "simulation-new"


#---------------------------------------------------------------------
# Mapped templates
#---------------------------------------------------------------------

template::list::create \
    -name mapped_templates \
    -multirow mapped_templates \
    -actions "{New Simulation From Template} $add_url" \
    -no_data "No templates have been mapped" \
    -elements {
        pretty_name {
            label "Template"
            orderby upper(w.pretty_name)
        }
        roles {
            label "Developed Roles / Total Roles"
            display_template {
                0 / 9
            }
        }
        props {
            label "Developed Tasks / Total Tasks"
            display_template {
                0 / 8
            }
        }
        delete {
            display_template {
                Delete
            }
        }
        copy {
            display_template {
                <u>Copy</u>
            }
        }
        cast {
            link_url_col cast_url
            display_template {
                Begin casting
            }
        }
    }

# TODO: update the mapped_p subquery for agents
# Simpler solution:
# type column with possible values:
# incomplete_template
# ready_template
# mapped_template
# simulation
#       and not exists (select 1
#                       from sim_roles sr,
#                        workflow_roles wr
#                       where sr.role_id = wr.role_id
#                       and sr.character_id is null
#                       and wr.workflow_id = w.workflow_id
#                       )
db_multirow -extend { cast_url } mapped_templates select_mapped_templates {
    select w.workflow_id,
           w.pretty_name
    from workflows w
    where w.object_id = :package_id
} {
    set cast_url [export_vars -base "cast-edit" { workflow_id }]
}
