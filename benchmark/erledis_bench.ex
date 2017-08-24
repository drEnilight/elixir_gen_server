server = Erledis.generate_gen_server
server.start_link
Enum.each(Enum.to_list(1..10_000), fn(x) -> server.set("hello", x) end)

Benchee.run(%{
  "set element"           => fn -> server.set("hello", "word") end,
  "get element"           => fn -> server.get("hello") end,

  "push element"          => fn -> server.push("hello", "word") end,
  "pop element"           => fn -> server.pop("hello") end,
}, time: 3)


# Name                   ips        average  deviation         median
# pop element       398.83 K        2.51 μs  ±1217.52%        2.00 μs
# push element      393.11 K        2.54 μs  ±1332.48%        2.00 μs
# get element        11.93 K       83.80 μs    ±58.63%       62.00 μs
# set element       0.0402 K    24856.21 μs    ±86.22%    16633.00 μs
#
# Comparison:
# pop element       398.83 K
# push element      393.11 K - 1.01x slower
# get element        11.93 K - 33.42x slower
# set element       0.0402 K - 9913.49x slower
