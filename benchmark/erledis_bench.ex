server = Erledis.generate_gen_server
server.start_link
Enum.each(Enum.to_list(1..10_000), fn(x) -> server.push("hello", x) end)

Benchee.run(%{
  "get element"           => fn -> server.get("hello") end,
  "push element"          => fn -> server.push("hello", "word") end,
  "pop element"           => fn -> server.pop("hello") end,
}, time: 3)
