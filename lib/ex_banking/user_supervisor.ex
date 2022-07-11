defmodule ExBanking.UserSupervisor do
  use DynamicSupervisor
  require Logger

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_user_server(user_string) do
    spec = {ExBanking.UserServer, user_string}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
