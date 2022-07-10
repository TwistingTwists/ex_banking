defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """
  alias ExBanking.Users
  alias ExBanking.Users.Server, as: UServer

  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_binary(user) do
    UServer.create_or_fetch_user(ExBanking.Users.Server, user)
    # case Users.create_user(user) do
    #   {:already_exisitng, user} -> {:error, :user_already_exists}
    #   {:new, user} -> :ok
    # end
  end

  def create_user(user) do
    {:error, :wrong_arguments}
  end

  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency)
      when is_binary(user) and is_binary(currency) and is_number(amount) do
    case Users.update_user_balance(user, amount, currency) do
      {:ok, user} ->
        {:ok, user.monies[currency] |> Float.round(2)}

      # pending - resume from here

      {:error, reason} ->
        {:error, reason}
    end
  end

  def deposit(_u, _a, _c) do
    {:error, :wrong_arguments}
  end
end
