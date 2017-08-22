defmodule Erledis do
  use GenServer

  # API

  def start_link(name) when is_binary(name) do
    s_name = String.to_atom(name)
    GenServer.start_link(__MODULE__, [], name: s_name)
  end

  @spec set(String.t(), String.t(), any) :: boolean
  def set(name, key, value) do
    case is_binary(key) do
      true  -> GenServer.call(server_pid(name), {:set, {key, value}})
      false -> error_message
    end
  end

  @spec get(String.t(), String.t()) :: list
  def get(name, key) do
    case is_binary(key) do
      true  -> GenServer.call(server_pid(name), {:get, key})
      false -> error_message
    end
  end

  @spec push(String.t(), String.t(), any) :: list
  def push(name, key, value) do
    case is_binary(key) do
      true  -> GenServer.call(server_pid(name), {:push, {key, value}})
      false -> error_message
    end
  end

  @spec pop(String.t(), String.t()) :: any
  def pop(name, key) do
    case is_binary(key) do
      true  -> GenServer.call(server_pid(name), {:pop, key})
      false -> error_message
    end
  end

  @spec del(String.t(), String.t()) :: boolean
  def del(name, key) do
    case is_binary(key) do
      true  -> GenServer.call(server_pid(name), {:del, key})
      false -> error_message
    end
  end

  @spec exists?(String.t(), String.t()) :: boolean
  def exists?(name, key) do
    case is_binary(key) do
      true  -> GenServer.call(server_pid(name), {:exists, key})
      false -> error_message
    end
  end

  @spec flushall(String.t()) :: boolean
  def flushall(name) do
    GenServer.call(server_pid(name), :flushall)
  end

  @spec server_pid(String.t()) :: pid
  defp server_pid(name) do
    s_name = String.to_atom(name)
    GenServer.whereis(s_name)
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
       nil -> map = Map.put(map, key, list = [value])
              {:reply, list, map}
      list -> map = Map.put(map, key, list = [value | list])
              {:reply, list, map}
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
