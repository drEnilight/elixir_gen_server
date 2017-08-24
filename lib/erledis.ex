defmodule Erledis do
  defmacro createGenServer(name) do
    quote do
      defmodule unquote(name) do
        use GenServer

        # API

        def start_link do
          GenServer.start_link(__MODULE__, [], name: __MODULE__)
        end

        @spec set(String.t(), any) :: boolean
        def set(key, value) do
          case is_binary(key) do
            true  -> GenServer.call(__MODULE__, {:set, {key, value}})
            false -> error_message()
          end
        end

        @spec get(String.t()) :: list
        def get(key) do
          case is_binary(key) do
            true  -> GenServer.call(__MODULE__, {:get, key})
            false -> error_message()
          end
        end

        @spec push(String.t(), any) :: list
        def push(key, value) do
          case is_binary(key) do
            true  -> GenServer.call(__MODULE__, {:push, {key, value}})
            false -> error_message()
          end
        end

        @spec pop(String.t()) :: any
        def pop(key) do
          case is_binary(key) do
            true  -> GenServer.call(__MODULE__, {:pop, key})
            false -> error_message()
          end
        end

        @spec del(String.t()) :: boolean
        def del(key) do
          case is_binary(key) do
            true  -> GenServer.call(__MODULE__, {:del, key})
            false -> error_message()
          end
        end

        @spec exists?(String.t()) :: boolean
        def exists?(key) do
          case is_binary(key) do
            true  -> GenServer.call(__MODULE__, {:exists, key})
            false -> error_message()
          end
        end

        @spec flushall :: boolean
        def flushall do
          GenServer.call(__MODULE__, :flushall)
        end

        defp error_message do
          "key argument must be a string"
        end

        # CALLBACKS

        def init(_) do
          map = %{}
          {:ok, map}
        end

        def handle_call({:set, {key, value}}, _from,  map) do
          case Map.get(map, key) do
            nil -> map = Map.put(map, key, [value])
            {:reply, true, map}
            list -> map = Map.put(map, key, list ++ [value])
            {:reply, true, map}
          end
        end

        def handle_call({:get, key}, _from, map) do
          case Map.get(map, key) do
            nil -> {:reply, [], map}
            list -> {:reply, list, map}
          end
        end

        def handle_call({:push, {key, value}}, _from,  map) do
          case Map.get(map, key) do
            nil -> map = Map.put(map, key, [value])
            {:reply, value, map}
            list -> map = Map.put(map, key, [value | list])
            {:reply, value, map}
          end
        end

        def handle_call({:pop, key}, _from,  map) do
          case Map.get(map, key) do
            nil -> {:reply, nil, map}
            list -> {last_value, list} = list |> List.pop_at(-1)
            map = Map.put(map, key, list)
            {:reply, last_value, map}
          end
        end

        def handle_call({:del, key}, _from, map) do
          case Map.get(map, key) do
            nil -> {:reply, false, map}
            list -> map = Map.delete(map, key)
            {:reply, true, map}
          end
        end

        def handle_call({:exists, key}, _from, map) do
          case Map.get(map, key) do
            nil -> {:reply, false, map}
            list -> {:reply, true, map}
          end
        end

        def handle_call(:flushall, _from, map) do
          map = %{}
          {:reply, true, map}
        end
      end
    end
  end

  def generate_gen_server do
    s_name = String.to_atom("server-" <> "#{:rand.uniform}")
    {:module, name, _, _} = createGenServer(s_name)
    name
  end
end
