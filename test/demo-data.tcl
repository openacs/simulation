# Procs returning demo data.
#
# Procs to support the Tclwebtest (HTTP level) testing and demo data setup
# of the simulation package.
#
# @author Peter Marklund

namespace eval ::twt::simulation {}
namespace eval ::twt::simulation::data {}

ad_proc ::twt::simulation::data::actors {} {
    return {
        Teacher
        Student
        Agent1
        Agent2
    }
}

ad_proc ::twt::simulation::data::characters {} {
    return {
        Bernadette         "Bernadette"
        MOTORHOME          "MOTORHOME"
        "A of Lawfirm X"   "Her lawyer"
        "A of Lawfirm Y"   "Its lawyer"
        "B of Lawfirm X"   "Partner firm X"
        "B of Lawfirm Y"   "Partner firm Y"
        "C of Lawfirm X"   "Secretary firm X"
        "C of Lawfirm Y"   "Secretary firm Y"
        "Portal"           "Library"          
    }
}

ad_proc ::twt::simulation::data::characters_ld {} {
    return {
    "Lok of Legisl. Dept."	"Member 1 of Legisl. Dept."
    "Peter of Legisl. Dept."	"Member 2 of Legisl. Dept."
    "Aernout of Legisl. Dept."	"Head of Legisl. Dept."
    "Jeroen of Legisl. Dept."	"Deputy Head of Legisl. Dept."
    "Laurens of Legisl. Dept."	"Chief of Legisl. Dept."
    "Fred Undraiser"		"Fundraiser"
    "A of ADC"			"Representative of ADC"	
    "Minister"			"Minister of Justice"          
    "General Student"		"Student"
    }
}

ad_proc ::twt::simulation::data::properties {} {
    return {
        "Demo Property 1" "Demo Property 1"
        "Demo Property 2" "Demo Property 2"
    }
}

ad_proc ::twt::simulation::data::tasks {} {
    return {
    "Ask information from Bernadette" {assigned_role "Her lawyer" recipient_role "Bernadette"}
    "Ask information from MOTORHOME" {assigned_role "Her lawyer" recipient_role "MOTORHOME"}
    "Ask information from opponent's lawyer 1" {assigned_role "Its lawyer" recipient_role "Her lawyer"}
    "Ask information from opponent's lawyer 2" {assigned_role "Her lawyer" recipient_role "Its lawyer"}
    "Ask information from library" {assigned_role "Her lawyer" recipient_role "Library"}
    "Ask information from partner" {assigned_role "Her lawyer" recipient_role "Partner firm X"}
    "Intervene" {assigned_role "Partner firm X" recipient_role "Her lawyer"}
    "Reply to intervention" {assigned_role "Her lawyer" recipient_role "Partner firm X"}
    "Give information as Bernadette" {assigned_role "Bernadette" recipient_role "Her lawyer"}
    "Give information as Motorhome" {assigned_role "MOTORHOME" recipient_role "Her lawyer"}
    "Make/edit draft report" {assigned_role "Her lawyer" recipient_role "Her lawyer"}
    "Edit draft report" {assigned_role "Her lawyer" recipient_role "Her lawyer"}
    "Give information to opponent's lawyer" {assigned_role "Her lawyer" recipient_role "Its lawyer"}
    "Send final report" {assigned_role "Her lawyer" recipient_role "Partner firm X"}
    "Send draft report" {assigned_role "Her lawyer" recipient_role "Partner firm X"}
    }
}

ad_proc ::twt::simulation::data::tasks_ld {} {
    return {
    "Write Proposal gr1" {assigned_role "Member 1 of Legisl. Dept." recipient_role "Head of Legisl. Dept."}
    "Write Proposal gr2" {assigned_role "Member 2 of Legisl. Dept." recipient_role "Deputy Head of Legisl. Dept."}
    "Write Opinion SHOULD BE AN ADDINFOTOPORTFOLIO gr1" {assigned_role "Fundraiser" recipient_role "Minister of Justice"}
    "Write Opinion SHOULD BE AN ADDINFOTOPORTFOLIO gr2" {assigned_role "Representative of ADC" recipient_role "Minister of Justice"}
    "Comment on Member2 Proposal SHOULD BE AN ADDINFOTOPORTFOLIO" {assigned_role "Head of Legisl. Dept." recipient_role "Minister of Justice"}
    "Comment on Member1 Proposal SHOULD BE AN ADDINFOTOPORTFOLIO" {assigned_role "Deputy Head of Legisl. Dept." recipient_role "Minister of Justice"}
    "Revise using Opinions and Comment from Head SHOULD BE AN ADDINFOTOPORTFOLIO" {assigned_role "Member 1 of Legisl. Dept." recipient_role "Minister of Justice"}
    "Revise using Opinions and Comment from Deputy SHOULD BE AN ADDINFOTOPORTFOLIO" {assigned_role "Member 2 of Legisl. Dept." recipient_role "Minister of Justice"}
    "Rate Comments SHOULD BE A REVIEWINFO" {assigned_role "Student" recipient_role "Minister of Justice"}
    "Rate Revisions SHOULD BE A REVIEWINFO" {assigned_role "Student" recipient_role "Minister of Justice"}
    "Learning evaluation DUMMY or ADDINFOTOPORTFOLIO" {assigned_role "Student" recipient_role "Minister of Justice"}
    "Write Definition based on Revision SHOULD BE AN ADDINFOTOPORTFOLIO" {assigned_role "Member 1 of Legisl. Dept." recipient_role "Minister of Justice"}
    "Elaborate the Revision SHOULD BE AN ADDINFOTOPORTFOLIO" {assigned_role "Member 2 of Legisl. Dept." recipient_role "Minister of Justice"}
    "Comment Revision of Member 1" {assigned_role "Head of Legisl. Dept." recipient_role "Minister of Justice"}
    "Comment Revision of Member 2" {assigned_role "Deputy Head of Legisl. Dept." recipient_role "Minister of Justice"}
    "Learning Evalution SHOULD BE A ADDINFOTOPORTFOLIO" {assigned_role "Student" recipient_role "Minister of Justice"}
    "Implementation of all received comments and opinions SHOULD BE AN ADDINFOTOPORTFOLIO gr1" {assigned_role "Member 2 of Legisl. Dept." recipient_role "Minister of Justice"}
    "Implementation of all received comments and opinions SHOULD BE AN ADDINFOTOPORTFOLIO gr2" {assigned_role "Member 2 of Legisl. Dept." recipient_role "Minister of Justice"}
    "Write law SHOULD BE AN ADDINFOTOPORTFOLIO gr1" {assigned_role "Member 1 of Legisl. Dept." recipient_role "Minister of Justice"}
    "Write law SHOULD BE AN ADDINFOTOPORTFOLIO gr2" {assigned_role "Member 1 of Legisl. Dept." recipient_role "Minister of Justice"}
    }   
}

ad_proc ::twt::simulation::data::tilburg_template_spec {} {
    return "simulatie_tilburg {
    description {Use case 1 template from Leiden team.}
    description_mime_type text/enhanced
    object_type acs_object
    package_key simulation
    pretty_name {
        Simulation Tilburg
    }
    roles {
        lawyer {
            pretty_name Lawyer
        }
        client {
            pretty_name Client
        }
        other_lawyer {
            pretty_name {
                Other lawyer
            }
        }
        other_client {
            pretty_name {
                Other client
            }
        }
        mentor {
            pretty_name Mentor
        }
        secretary {
            pretty_name Secretary
        }
    }
    actions {
        initialize {
            initial_action_p t
            new_state started
            pretty_name Initialize
            attachment_num 0
        }
        ask_client {
            assigned_role lawyer
            assigned_states started
            new_state open
            pretty_name {
                Ask client
            }
            attachment_num 1
            recipient_role client
        }
        ask_client_for_more_information {
            assigned_role lawyer
            enabled_states open
            pretty_name {Ask Client for more information}
            attachment_num 1
            recipient_role client
        }
        consult_lawyer {
            assigned_role lawyer
            enabled_states open
            pretty_name {
                Consult lawyer
            }
            attachment_num 1
            recipient_role other_lawyer
        }
        visit_the_library {
            assigned_role lawyer
            enabled_states open
            pretty_name {Visit the library}
            attachment_num 0
            recipient_role lawyer
        }
        consult_mentor {
            assigned_role lawyer
            enabled_states open
            pretty_name {
                Consult mentor
            }
            attachment_num 1
            recipient_role mentor
        }
        mentor_intervenes {
            assigned_role mentor
            enabled_states open
            pretty_name {
                Mentor intervenes
            }
            attachment_num 1
            recipient_role lawyer
        }
        consult_secretary {
            assigned_role lawyer
            enabled_states open
            pretty_name {
                Consult secretary
            }
            attachment_num 1
            recipient_role secretary
        }
        write_legal_advice {
            assigned_role lawyer
            assigned_states open
            new_state written
            pretty_name {Write legal advice}
            attachment_num 1
            recipient_role secretary
        }
        correct_spell_check_etc {
            assigned_role secretary
            enabled_states written
            new_state done
            pretty_name {Correct, spell-check, etc.}
            attachment_num 1
            recipient_role client
        }
    }
    states {
        started {
            pretty_name Started
        }
        open {
            pretty_name Open
        }
        written {
            pretty_name Written
        }
        done {
            pretty_name Done
        }
    }
}"
}
