set package_id [ad_conn package_id]
set return_url [ad_return_url]
set parameters_url [export_vars -base "/shared/parameters" {package_id return_url}]

set map_help_url [ad_conn url]object/[parameter::get -package_id $package_id -parameter MapHelpFile]