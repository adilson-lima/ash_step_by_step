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
    # Defaults to `true`, use this to disable authorization for the entire API (you probably only want this while prototyping)
    authorize?(false)
  end
end
