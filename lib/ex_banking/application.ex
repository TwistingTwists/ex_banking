defmodule ExBanking.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, [name: ExBanking.Registry.User, keys: :unique]},
      {Registry, [name: ExBanking.Registry.UserRateLimiter, keys: :unique]},
      {DynamicSupervisor, [name: ExBanking.UserSupervisor, strategy: :one_for_one]},
      {DynamicSupervisor, [name: ExBanking.RateLimiterSupervisor, strategy: :one_for_one]}

      # ExBanking.RateLimiterSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExBanking.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
