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
    # Defaults to `true`, use this to disable authorization for the entire API (you probably only want this while prototyping)
    authorize?(false)
  end
end
