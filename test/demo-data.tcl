set actors_list {
    Teacher
    Student
    Agent1
    Agent2
}

array set characters {
    Bernadette         "Bernadette"
    MOTORHOME          "MOTORHOME"
    "A of Lawfirm X"   "Her lawyer"
    "A of Lawfirm Y"   "Its lawyer"
    "B of Lawfirm X"   "Partner firm X"
    "B of Lawfirm Y"   "Partner firm Y"
    "C of Lawfirm X"   "Secretary firm X"
    "C of Lawfirm Y"   "Secretary firm Y"
    "Portal"           "Library"          
    "Lok of Legisl. Dept."		"Member 1 of Legisl. Dept."
    "Peter of Legisl. Dept."	"Member 2 of Legisl. Dept."
    "Aernout of Legisl. Dept."	"Head of Legisl. Dept."
    "Jeroen of Legisl. Dept."	"Deputy Head of Legisl. Dept."
    "Laurens of Legisl. Dept."	"Chief of Legisl. Dept."
    "Fred Undraiser"		"Fundraiser"
    "A of ADC"			"Representative of ADC"	
    "Minister"			"Minister of Justice"          
    "General Student"		"Student"
}

array set characters_ld {
    "Lok of Legisl. Dept."		"Member 1 of Legisl. Dept."
    "Peter of Legisl. Dept."	"Member 2 of Legisl. Dept."
    "Aernout of Legisl. Dept."	"Head of Legisl. Dept."
    "Jeroen of Legisl. Dept."	"Deputy Head of Legisl. Dept."
    "Laurens of Legisl. Dept."	"Chief of Legisl. Dept."
    "Fred Undraiser"		"Fundraiser"
    "A of ADC"			"Representative of ADC"	
    "Minister"			"Minister of Justice"          
    "General Student"		"Student"
}

array set properties {
    "Demo Property 1" "Demo Property 1"
    "Demo Property 2" "Demo Property 2"
}

array set tasks {
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

array set tasks_ld {
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
