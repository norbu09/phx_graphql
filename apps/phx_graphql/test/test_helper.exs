IO.write("Running CouchDB migration...")
CouchViewManager.migrate()
IO.puts("...done")

ExUnit.start()
