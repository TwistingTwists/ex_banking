defmodule ExBanking.RateLimiterServer do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, 0, name: via(name))
  end

  def calls_allowed?(name) do
    GenServer.call(via(name), :call)
  end

  def processed(name) do
    GenServer.call(via(name), :processed)
  end

  @impl GenServer
  def init(count) do
    {:ok, count}
  end

  @impl GenServer
  def handle_call(:call, _from, count) do
    {reply_message, new_count} =
      cond do
        count + 1 > 10 ->
          {:too_many_requests_to_user, count}

        count + 1 <= 10 ->
          # {count + 1, count + 1}
          {:ok, count + 1}
      end

    {:reply, reply_message, new_count}
  end

  @impl GenServer
  def handle_call(:processed, _from, count) do
    # IO.inspect("=----=----=---- #{count} =----=----=----")
    {:reply, count - 1, count - 1}
  end

  defp via(name) do
    {:via, Registry, {ExBanking.Registry.UserRateLimiter, name}}
  end
end
