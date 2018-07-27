IO.write("Running CouchDB migration...")
res = CouchViewManager.migrate()
IO.puts("...done")

ExUnit.start()
