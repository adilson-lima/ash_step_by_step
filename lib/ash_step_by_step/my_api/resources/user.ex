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
