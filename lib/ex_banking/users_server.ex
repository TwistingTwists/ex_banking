defmodule ExBanking.Users.Server do
  # alias ExBanking.{Users, User}
  # alias ExBanking.Users.Server
  use GenServer
  alias ExBanking.User
  alias ExBanking.Users
  alias ExBanking.Users.Server

  ############## client  ##############

  def start_link(opts) do
    opts |> IO.puts()
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    # GenServer.start_link(CLI, name: :beer )
  end

  def create_or_fetch_user(user_server_pid, user_string) do
    GenServer.call(user_server_pid, {:create_or_fetch_user, user_string})
  end

  def update_user_balance(user_server_pid, amount, currency) do
    GenServer.call(user_server_pid, {:update_balance, amount, currency})
  end

  ############## server  ##############
  @impl GenServer
  def init(_) do
    # {:ok, %Users{}}
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:create_or_fetch_user, new_user}, _from, users) do
    {reply_message, new_user_list} =
      case Users.create_or_fetch_user(users, new_user) do
        {:already_exisitng, _user} ->
          {{:error, :user_already_exists}, users}

        {:new, user} ->
          {:ok, Map.put(users, new_user, user)}
      end

    {:reply, reply_message, new_user_list}
  end

  @impl GenServer
  def handle_call({:update_balance, amount, currency}, _from, users) do
    # todo get user string somehow
    case(Users.update_user_balance(users, "default user ", amount, currency)) do
      {:error, :user_does_not_exist} -> :error
      # todo format the data to return + update users list
      {:ok, user} -> user
    end

    # todo un=hardcode reply
    default_user = %User{name: "default user", monies: %{"USD" => 100}}
    new_user_list = users
    {:reply, default_user, new_user_list}
  end
end
