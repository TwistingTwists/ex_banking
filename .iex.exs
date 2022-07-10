alias ExBanking, as: ExB

alias ExBanking.{Users, User}

# users_list = %Users{
#   entries: %{
#     "middle" => %User{name: "middle", monies: %{"USD" => 60, "INR" => 100}},
#     "kangal" => %User{name: "kangal", monies: %{}},
#     "rich" => %User{name: "rich", monies: %{"EUR" => 1000, "INR" => 20}}
#   }
# }


users_list =%{
    "middle" => %User{name: "middle", monies: %{"USD" => 60, "INR" => 100}},
    "kangal" => %User{name: "kangal", monies: %{}},
    "rich" => %User{name: "rich", monies: %{"EUR" => 1000, "INR" => 20}}
  }


# :dbg.start()


# defmodule CLI do
#   alias ExBanking.Users.Server
#   def starting()do
#     {:ok,pid} = Server.start()
#     pid |> IO.inspect()
#     Server.create_or_fetch_user(CLI,"iex_user")
#   end
# end


# alias ExBanking.Users.Server
# {:ok,pid} = Server.start_link()
# pid |> IO.inspect()
# :sys.trace(pid,true)

# Server.create_or_fetch_user(pid,"iex_user")
# :sys.get_state(Server)
# # Server.create_or_fetch_user(pid,"iex_user")
