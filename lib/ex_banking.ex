defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """
  # alias ExBanking.Users
  alias ExBanking.UserSupervisor, as: USup
  alias ExBanking.UserServer, as: UServer
  alias ExBanking.RateLimiterSupervisor, as: RSup
  alias ExBanking.RateLimiterServer, as: RLServer

  ############## create_user  ##############
  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_binary(user) do
    # todo for testing. remove later
    Process.sleep(1000)

    # case RSup.add_user_rate_limit_server(user) do
    #   {:ok, pid} ->
    #     case RLServer.calls_allowed?(user) do
    #       :ok ->
    case USup.add_user_server(user) do
      {:ok, pid} ->
        # IO.inspect("PID for #{user} is started at #{inspect(pid)} ")
        RSup.add_user_rate_limit_server(user)
        :ok

      {:error, {:already_started, pid}} ->
        # IO.inspect(pid)
        {:error, :user_already_exists}
    end

    # :too_many
    #     end

    #   {:error, {:already_started, pid}} ->
    #     # make sure other user server is also running?
    #     {:error, :user_already_exists}
    # end
  end

  def create_user(_user) do
    {:error, :wrong_arguments}
  end

  ############## deposit  ##############
  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency)
      when is_binary(user) and is_binary(currency) and is_number(amount) and amount >= 0 do
    # check if user exists
    case does_exist?(user) do
      [] ->
        :user_does_not_exist

      _ ->
        UServer.deposit(user, amount, currency)
    end
  end

  def deposit(_u, _a, _c) do
    {:error, :wrong_arguments}
  end

  # defp via_user_registry(user) do
  #   {:via, Registry, {ExBanking.Registry.User, name}}
  # end

  defp does_exist?(user) do
    Registry.lookup(ExBanking.Registry.User, user)
    # == []
  end
end
