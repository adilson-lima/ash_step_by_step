defmodule AshStepByStep.Schema do
  use Absinthe.Schema

  @apis [AshStepByStep.MyApi]

  use AshGraphql, apis: @apis

  query do
  end

  mutation do
  end
end
