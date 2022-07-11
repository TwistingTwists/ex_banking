# defmodule ExBanking.Users.Server do
defmodule ExBanking.UserServer do
  use GenServer

  alias ExBanking.User
  # alias ExBanking.Users
  alias ExBanking.UserServer, as: Server
  alias ExBanking.RateLimiterServer, as: RLServer

  ############## client  ##############

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via(name))
  end

  def deposit(user_string, amount, currency) do
    # case RLServer.calls_allowed?(user_string) do
    #   :too_many_requests_to_user ->
    #     :too_many_requests_to_user

    #   count ->
    #     IO.inspect([count, "--incrased"])
    #     # if calls can be made, update deposit
    #     # one amount >= 0 guard clause in UServer also. can remove it?
    #     # return_value = UServer.deposit(user, amount, currency)

    #     return_val = GenServer.call(via(user_string), {:deposit, amount, currency})
    #     count_value = RLServer.processed(user_string)
    #     IO.inspect([count_value, " -- decreased"])
    #     return_val
    # end
    # |> with_response()

    RLServer.calls_allowed?(user_string)
    |> to_deposit(user_string, amount, currency)
  end

  def withdraw(user_string, amount, currency) do
    RLServer.calls_allowed?(user_string)
    |> to_withdraw(user_string, amount, currency)
  end

  def get_balance(user_string, currency) do
    RLServer.calls_allowed?(user_string)
    |> to_balance(user_string, currency)
  end

  ############## server  ##############
  @impl GenServer
  def init(name) do
    {:ok, User.new(name)}
  end

  @impl GenServer
  def handle_call({:deposit, amount, currency}, _from, user) do
    Process.sleep(300)
    {:ok, updated_user} = User.deposit(user, amount, currency)
    # {:ok,new_balance}
    return_value = {:ok, updated_user.monies[currency] |> Float.round(2)}

    # call rate limiting server and tell that entry has been processed
    # this is handle_cast
    # count_value = RLServer.processed(user.name)
    {:reply, return_value, updated_user}
  end

  def handle_call({:withdraw, amount, currency}, _from, user) do
    {return_value, updated_user} =
      case User.withdraw(user, amount, currency) do
        {:not_enough_money, updated_user} ->
          {{:error, :not_enough_money}, updated_user}

        {:ok, updated_user} ->
          # {:ok,new_balance}
          {{:ok, updated_user.monies[currency] |> Float.round(2)}, updated_user}
      end

    {:reply, return_value, updated_user}
  end

  def handle_call({:get_balance, currency}, _from, user) do
    {:ok, updated_user} = User.get_balance(user, currency)
    IO.inspect(updated_user)
    balance = Map.get(updated_user.monies, currency) |> Float.round(2)
    {:reply, balance, updated_user}
  end

  def handle_call({:send, to_user, amount, currency}, _from, from_user) do
    # if from_user can withdraw , then send the money to to_user
    {return_value, updated_from_user} =
      case User.withdraw(from_user, amount, currency) do
        {:not_enough_money, updated_user} ->
          {{:error, :not_enough_money}, updated_user}

        {:ok, updated_user} ->
          from_user_balance = updated_user.monies[currency] |> Float.round(2)
          {:ok, to_user_balance} = GenServer.call(via(to_user), {:deposit, amount, currency})
          count_value = RLServer.processed(to_user)
          {{:ok, from_user_balance, to_user_balance}, updated_user}
      end

    {:reply, return_value, updated_from_user}
  end

  ########## private  ##########
  def via(name) do
    {:via, Registry, {ExBanking.Registry.User, name}}
  end

  defp to_deposit(:too_many_requests_to_user, _, _, _), do: {:error, :too_many_requests_to_user}

  defp to_deposit(:ok, user_string, amount, currency) do
    return_val = GenServer.call(via(user_string), {:deposit, amount, currency})
    count_value = RLServer.processed(user_string)
    # IO.inspect([count_value, " -- decreased"])
    return_val
  end

  defp to_withdraw(:too_many_requests_to_user, _, _, _), do: {:error, :too_many_requests_to_user}

  defp to_withdraw(:ok, user_string, amount, currency) do
    return_val = GenServer.call(via(user_string), {:withdraw, amount, currency})
    count_value = RLServer.processed(user_string)
    return_val
  end

  defp to_balance(:too_many_requests_to_user, _, _), do: {:error, :too_many_requests_to_user}

  defp to_balance(:ok, user_string, currency) do
    return_val = GenServer.call(via(user_string), {:get_balance, currency})
    # IO.inspect("------------------------")
    # IO.inspect(return_val)
    count_value = RLServer.processed(user_string)
    # IO.inspect([count_value, " -- processed withdraw"])
    return_val
  end

  # defp to_user_send(:too_many_requests_to_user, _, _, _, _),
  #   do: {:error, :too_many_requests_to_receiver}

  # defp to_user_send(:ok, from_user, to_user, amount, currency) do
  #   RLServer.calls_allowed?(from_user)
  #   |> from_user_send(from_user, to_user, amount, currency)
  # end
  def send(from_user, to_user, amount, currency) do
    RLServer.calls_allowed?(from_user)
    |> from_user_send(from_user, to_user, amount, currency)
  end

  defp from_user_send(:too_many_requests_to_user, _, _, _, _),
    do: {:error, :too_many_requests_to_sender}

  defp from_user_send(:ok, from_user, to_user, amount, currency) do
    return_val = GenServer.call(via(from_user), {:send, to_user, amount, currency})
    count_val = RLServer.processed(from_user)
    return_val
  end
end
