defmodule AshStepByStepWeb.MyApi.Router do
  use AshJsonApi.Api.Router,
    apis: [AshStepByStep.MyApi],

    # optionally a json_schema route
    json_schema: "/json_schema"

  # optionally an open_api route
  # open_api: "/open_api"
end
