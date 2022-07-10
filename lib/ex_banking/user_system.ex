defmodule User.System do
  def start_link do
    Supervisor.start_link(
      [
        # Todo.Metrics,
        # Todo.ProcessRegistry,
        # Todo.Database,
        ExBanking.Users.Server
      ],
      strategy: :one_for_one
    )
  end
end
