ad_page_contract {
    Enroll a user in a simulation and display confirmation or redirect for self-casting if appropriate.

    @author Joel Aufrecht
} {
    workflow_id:integer
}

auth::require_login
# TODO (.25h): integrate sim title into page title
set page_title "Enrollment complete"
set context [list [list "." "SimPlay"] $page_title]

# TODO (5h): implement the pseudocode in this page

# verify that the user has permission to enroll:
#    simulation is open enrollment OR
#    user has invitation for this sim
# if not, display error message "sorry, you don't have permission to enroll in this simulation" and link to openacs page for the simulation's owner or email or something

# enroll the user in the simulation
# simulation::template::enroll -workflow_id $workflow_id  (should auto-detect user_id)

# case simulation casting type:
#   :auto-casting
#     display this message now
#     "You have been enrolled in @simulation.name@.  This simulation will begin on @begin_date@"
#   :group casting
#     redirect to cast
#   :open casting
#     redirect to cast
