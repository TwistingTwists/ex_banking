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

    RLServer.calls_allowed?(user_string)
    |> to_deposit(amount, currency)
  end

  ############## server  ##############
  @impl GenServer
  def init(name) do
    {:ok, User.new(name)}
  end

  @impl GenServer
  def handle_call({:get_balance, currency}, _from, user) do
    return_value = {:ok, user.monies[currency]}
    {:reply, return_value, user}
  end

  @impl GenServer
  def handle_call({:deposit, amount, currency}, _from, user) do
    Process.sleep(300)
    updated_user = User.deposit(user, amount, currency)
    # {:ok,new_balance}
    return_value = {:ok, updated_user.monies[currency] |> Float.round(2)}

    # call rate limiting server and tell that entry has been processed
    # this is handle_cast
    # count_value = RLServer.processed(user.name)
    {:reply, return_value, updated_user}
  end

  ########## private company ##########
  defp via(name) do
    {:via, Registry, {ExBanking.Registry.User, name}}
  end

  defp to_deposit(:too_many_requests_to_user, _, _), do: :too_many_requests_to_user

  defp to_deposit(user_string, amount, currency) do
    return_val = GenServer.call(via(user_string), {:deposit, amount, currency})
    count_value = RLServer.processed(user_string)
    IO.inspect([count_value, " -- decreased"])
    return_val
  end
end
