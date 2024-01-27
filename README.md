# AshStepByStep

Step by step to create a new project with elixir, phoenix, ash, graphql, rest and database postgres.

### Step 01
Create a new phoenix project.

      $ mix phx.new ash_step_by_step

### Step 02
Initialize the postgres database, case are you using postgres with docker-compose, run:

      $ docker-compose up -d

### Step 03
Add Ash libraries in file ***mix.exs***
```elixir
...
defp deps do 
  [
    ...,
    {:ash, "~> 2.17"},
    {:ash_postgres, "~> 1.3"},
    {:ash_phoenix, "~> 1.2"},
    {:ash_graphql, "~> 0.26.8"},
    {:ash_json_api, "~> 0.34.1"}
  ]
end
```

### Step 04
Install all dependencies

      $ mix deps.get

### Step 05
Configure Ash formatter to the file ***formatter.exs***
```elixir
[
  import_deps: [:ecto, :ecto_sql, :phoenix, :ash, :ash_phoenix, :ash_postgres, :ash_graphql],
  ...
]
```
### Step 06
Edit file ***repo.ex*** to ash support
```elixir
defmodule AshStepByStep.Repo do
  use AshPostgres.Repo, otp_app: :helpdesk

   # Installs Postgres extensions that ash commonly uses
  def installed_extensions do
    ["uuid-ossp", "citext"]
  end
end
```

### Step 07
Edit file ***config.exs*** to add Ash suport

```elixir
config :ash_step_by_step, :default_managed_relationship_type_name_template, :action_name
config :my_project, ash_apis: [AshStepByStep.MyApi]
```


### Step 08
Create file ***/ash_step_by_step/schema.ex*** to graphql
```elixir
defmodule AshStepByStep.Schema do
  use Absinthe.Schema

  @apis [AshStepByStep.MyApi]

  use AshGraphql, apis: @apis

  query do
  end

  mutation do
  end
end

```

### Step 09
Create a file resource ***/ash_step_by_step/my_api/resources/user.ex***
```elixir
defmodule AshStepByStep.MyApi.Resources.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshGraphql.Resource,
      AshJsonApi.Resource
    ]

  postgres do
    table "users"
    repo AshStepByStep.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string
    attribute :email, :string
  end

  actions do
    defaults [:create, :update, :read]
  end

  graphql do
    type :user

    queries do
      get :get_user, :read
      list :list_users, :read
    end

    mutations do
      create :create_user, :create
      update :update_user, :update
    end
  end
end
```

### Step 10
Create a api file ***/my_api/my_api.ex*** and add resource

```elixir
defmodule AshStepByStep.MyApi do
  use Ash.Api,
    extensions: [
      AshGraphql.Api,
      AshJsonApi
    ]

  resources do
    resource AshStepByStep.MyApi.Resources.User
  end

  graphql do
    # Defaults to `true`, use this to disable authorization for the entire API 
    authorize?(false)
  end
end
```


### Step 10
Configure phoenix router in file ***ash_step_by_step_web/router.ex***
```elixir
  ...

  pipeline :graphql do
    plug AshGraphql.Plug
  end

  scope "/" do
    pipe_through [:graphql]

    forward "/gql", Absinthe.Plug, schema: AshStepByStep.Schema

    forward "/playground",
            Absinthe.Plug.GraphiQL,
            schema: AshStepByStep.Schema,
            interface: :playground
  end

  scope "/", AshStepByStepWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  ...
```

### Step 11
Create the database and create the first migration

      $ mix ash_postgres.create
      $ mix ash_postgres.generate_migrations --name create_user_table
      $ mix ash_postgres.migrate

### Step 12
Now you can run the server

      $ mix phx.server

### Step 13
Finally you can access graphql interface to test and run your graphql queries:

Access: http://localhost:4000/playground