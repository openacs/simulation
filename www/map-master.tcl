set package_id [ad_conn package_id]
set return_url [ad_return_url]
set parameters_url [export_vars -base "/shared/parameters" {package_id return_url}]
