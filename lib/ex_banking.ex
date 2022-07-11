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

    with_user_does_not_exist_error(ExBanking.UserServer, :deposit, [user, amount, currency])
    # case does_exist?(user) do
    #   [] ->
    #     {:error, :user_does_not_exist}

    #   _ ->
    #     UServer.deposit(user, amount, currency)
    # end
  end

  def deposit(_u, _a, _c) do
    {:error, :wrong_arguments}
  end

  ############## withdraw  ##############
  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(user_string, amount, currency)
      when is_binary(user_string) and is_number(amount) and amount > 0 and is_binary(currency) do
    with_user_does_not_exist_error(ExBanking.UserServer, :withdraw, [
      user_string,
      amount,
      currency
    ])

    #     case does_exist?(user_string) do
    #   [] ->
    #     {:error, :user_does_not_exist}

    #   _ ->
    #     UServer.withdraw(user_string, amount, currency)
    # end
  end

  def withdraw(_user, _amount, _currency) do
    {:error, :wrong_arguments}
  end

  # Decreases user’s balance in given currency by amount value
  # Returns new_balance of the user in given format

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) when is_binary(user) and is_binary(currency) do
    with_user_does_not_exist_error(ExBanking.UserServer, :get_balance, [user, currency])
  end

  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) ::
          {:ok, from_user_balance :: number, to_user_balance :: number}
          | {:error,
             :wrong_arguments
             | :not_enough_money
             | :sender_does_not_exist
             | :receiver_does_not_exist
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency)
      when is_binary(from_user) and is_binary(to_user) and is_binary(currency) and
             is_number(amount) and amount > 0 do
    case does_exist?(from_user) do
      [] ->
        {:error, :sender_does_not_exist}

      _ ->
        case does_exist?(to_user) do
          [] ->
            {:error, :receiver_does_not_exist}

          _ ->
            UServer.send(from_user,to_user,amount,currency)
        end
    end
  end

  def send(_f, _t, _a, _c), do: {:error, :wrong_arguments}

  defp does_exist?(user) do
    Registry.lookup(ExBanking.Registry.User, user)
    # == []
  end

  def with_user_does_not_exist_error(m, f, arguments) do
    # [mfa ] = https://hexdocs.pm/elixir/master/Kernel.html#apply/3
    [user | _tail] = arguments

    case does_exist?(user) do
      [] ->
        {:error, :user_does_not_exist}

      _ ->
        Kernel.apply(m, f, arguments)
    end
  end
end
