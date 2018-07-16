# Phoenix + GraphQL starter

To get started run `new_project` from the root directory and it will create a
new project with everything set up ready to work on your API.

## included included in this starter

This starter includes the following bits, already configured and ready to go:
- CouchDB adaptor in your main app, configured for a dev DB, review 
  `apps/[your app]/config/dev.exs` for the connection details
- CouchDB view migrator so you can maintain your views in elixir code and they
  get utomatically updated in CouchDB on application start
- Apsinthe for your GraphQL needs. Documentation is under https://hexdocs.pm/absinthe
- Distillery for release bundling. Documentation is under https://hexdocs.pm/distillery/getting-started.html
