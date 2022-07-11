defmodule ExBanking.Users do
  alias ExBanking.{User,Users}
  # defstruct entries: %{}

  def create_or_fetch_user(users, user_string) do
    # pass list of all users from GenServer - which stores and manages users
    case Map.fetch(users, user_string) do
      :error ->
        # {create user  }
        {:new, User.new(user_string)}

      {:ok, user} ->
        {:already_exisitng, user}
    end
  end

  def update_user_balance(users, user_string, amount, currency) do
    case Map.fetch(users, user_string) do
      :error -> {:error, :user_does_not_exist}
      {:ok, user} -> {:ok, User.update_currency_balance(user, amount, currency)}
    end
  end

  # def update_user_balance(_, _), do: {:error, :wrong_arguments}
end
