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
- `comeonin` for authentication handling backed into CouchDB
- `guardian` for JWT handling
- `create-react-app` for a React frontend sitting on top of Phoenix
- Apollo for GraphQL handling within the React app
- Distillery for release bundling. Documentation is under https://hexdocs.pm/distillery/getting-started.html
- `dyalixer` for type checking

## Getting started

To fire up `phx_graphql` fom your development environment you need:
- CouchDB running
- this code base

After checkout please configure `apps/phx_graphql/config/dev.exs` and set your _local_ CouchDB parameter.

*WARNING:* this has to be your local setup as we will dynamically create DBs,
update views and so on and really dont want to do that on our production
setup while developing!

Then, just fire up the `phx_graphql` like any other Phoenix app with `$ iex -S mix phx.server`.

After you have a running `phx_graphql` go to http://localhost:4000/ and create a user,
log in and in your profile create an API key. We will need this API key for
interacting with the GraphQL API

The GraphQL API can be inspected and worked with interactively here:
http://localhost:4000/graphiql
the API endpoint is:
http://localhost:4000/api

On startup `phx_graphql` will create a local CouchDB database called `phx_graphql` and add
all views it needs automatically.

## Project layout

### `apps/phx_graphql`

This is where all the data definition and basic app logic goes. It acts as an
interface for the API layer to the underlying code. Treat this as your "model"
layer to make sure we define records in one place and know how they are
populated from the outside world.

### `apps/phx_graphql_web/`

This is the "web" layer. It exposes the GraphQL API as well as some helper
pages for creating new users, manage API tokens and so on. Treat this as your
"view" layer where all bits presentation go but no actual application logic.

### `apps/z_integration/`

A placeholder for some umbrella wide test cases, DB cleanup and other bits that
don't really fit anywhere else

## Testing

To make testing work you need a running CouchDB and configure
`apps/phx_graphql/config/test.exs` to work for your local DB. During testing a
`phx_graphql_test` DB will be created and trashed after the test. 

*IMPORTANT:* don't use a local DB called `phx_graphql_test` for local development as
it will get nuked when running the tests!

## Links

- icons: https://feathericons.com/
