defmodule ExBanking.User do
  alias ExBanking.User
  # @enforce_keys [:name]

  @doc """
  %User{
    name: "Dhan",
    monies: %{
      "USD" => 60,
      "INR" => 70
    }
  }
  """
  defstruct name: nil, monies: %{}

  def new(user_string) do
    %User{name: user_string, monies: %{}}
  end

  def update_currency_balance(user, amount, currency) do
    case Map.fetch(user.monies, currency) do
      :error ->
        # that currency did not exist, so create it in monies
        new_monies = Map.put(user.monies, currency, add_to_balance(0.00, amount))
        %{user | monies: new_monies}

      {:ok, balance} ->
        # common function for deposit or withdraw
        new_monies = Map.put(user.monies, currency, add_to_balance(balance, amount))
        %{user | monies: new_monies}
    end
  end

  # def update_user_balance(_, _), do: :wrong_arguments

  defp add_to_balance(balance, amount) do
    if balance + amount < 0 do
      # withdraw not possible
      :not_enough_money
    else
      balance + amount
    end
  end
end
