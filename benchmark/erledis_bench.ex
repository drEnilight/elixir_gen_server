server = Erledis.generate_gen_server
server.start_link
Enum.each(Enum.to_list(1..10_000), fn(x) -> server.set("hello", x) end)

Benchee.run(%{
  "set element"           => fn -> server.set("hello", "word") end,
  "get element"           => fn -> server.get("hello") end,

  "push element"          => fn -> server.push("hello", "word") end,
  "pop element"           => fn -> server.pop("hello") end,
}, time: 3)
