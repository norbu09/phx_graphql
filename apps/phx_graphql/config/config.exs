use Mix.Config

# CouchDB view migrator
config :couch_view_manager, views: ["user", "things"]

import_config "#{Mix.env()}.exs"
