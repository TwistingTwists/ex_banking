defmodule ExBanking.RateLimiterSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_user_rate_limit_server(user_string) do
    spec = {ExBanking.RateLimiterServer, user_string}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
