# AshStepByStep

A simple project using Ash framework is one that defines a set of resources and actions that model your domain, and then derives external APIs such as GraphQL or JSON:API from them. 

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
Configure Ash formatter to the file ***formatter.exs***
```elixir
[
  import_deps: [:ecto, :ecto_sql, :phoenix, :ash, :ash_phoenix, :ash_postgres, :ash_graphql],
  ...
]
```

### Step 05
Install all dependencies

      $ mix deps.get


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
Create a file resource ***/ash_step_by_step/api/resources/user.ex***
```elixir
defmodule AshStepByStep.Api.Resources.User do
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

  json_api do
    type "user"

    routes do
      base("/users")

      get(:read)
      index :read
      post(:create)
    end
  end

end
```


### Step 08
Create a api file ***/api.ex*** and add resource

```elixir
defmodule AshStepByStep.Api do
  use Ash.Api,
    extensions: [
      AshGraphql.Api,
      AshJsonApi.Api
    ]

  resources do
    resource AshStepByStep.Api.Resources.User
  end

  graphql do
    # Defaults to `true`, use this to disable authorization for the entire API 
    authorize?(false)
  end
end
```

### Step 09
Create file ***/ash_step_by_step/schema.ex*** to graphql
```elixir
defmodule AshStepByStep.Schema do
  use Absinthe.Schema

  @apis [AshStepByStep.Api]

  use AshGraphql, apis: @apis

  query do
  end

  mutation do
  end
end

```


### Step 10
Create a separate router in ***/ash_step_by_step_web/api/router.ex**, this module to work with your APIs
```elixir
defmodule AshStepByStepWeb.Api.Router do
  use AshJsonApi.Api.Router,
    apis: [AshStepByStep.Api],

    # optionally a json_schema route
    json_schema: "/json_schema"

  # optionally an open_api route
  # open_api: "/open_api"
end
```

### Step 11
Edit file ***config.exs*** to add Ash suport

```elixir
# config/config.exs
config :mime, :types, %{
  "application/vnd.api+json" => ["json"]
}

config :mime, :extensions, %{
  "json" => "application/vnd.api+json"
}

config :ash, :utc_datetime_type, :datetime

config :ash_step_by_step, :default_managed_relationship_type_name_template, :action_name
config :ash_step_by_step, ash_apis: [AshStepByStep.Api]
```


### Step 12
Recompile the mime:

      $ mix deps.compile mime --force





### Step 13
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

  

  scope "/api/json" do
    pipe_through(:api)

    forward "/", AshStepByStepWeb.Api.Router
  end

  ...
```

### Step 14
Create the database and create the first migration

      $ mix ash_postgres.create
      $ mix ash_postgres.generate_migrations --name create_user_table
      $ mix ash_postgres.migrate

### Step 15
Now you can run the server
      
      $ mix phx.server

### Step 16
List Ash routes in iex

    iex(1)> AshStepByStep.Api.Resources.User |> AshJsonApi.Resource.Info.routes()

### Step 17
Finally you can access graphql interface to test and run your graphql queries:

Access graphql: http://localhost:4000/playground

api rest: http://localhost:4000/api/json/users