defmodule AshStepByStep.Repo do
  use AshPostgres.Repo,
    otp_app: :ash_step_by_step
end
