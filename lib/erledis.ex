defmodule Erledis do
  use GenServer

  # API

  def start_link do
    GenServer.start_link(__MODULE__, :erledis, name: :erledis)
  end

  @spec set(String.t(), any) :: boolean
  def set(key, value) do
    case is_binary(key) do
      true  -> GenServer.call(:erledis, {:set, {key, value}})
      false -> error_message
    end
  end

  @spec get(String.t()) :: list
  def get(key) do
    case is_binary(key) do
      true  -> GenServer.call(:erledis, {:get, key})
      false -> error_message
    end
  end

  @spec push(String.t(), any) :: list
  def push(key, value) do
    case is_binary(key) do
      true  -> GenServer.call(:erledis, {:push, {key, value}})
      false -> error_message
    end
  end

  @spec pop(String.t()) :: any
  def pop(key) do
    case is_binary(key) do
      true  -> GenServer.call(:erledis, {:pop, key})
      false -> error_message
    end
  end

  @spec del(String.t()) :: boolean
  def del(key) do
    case is_binary(key) do
      true  -> GenServer.call(:erledis, {:del, key})
      false -> error_message
    end
  end

  @spec exists?(String.t()) :: boolean
  def exists?(key) do
    case is_binary(key) do
      true  -> GenServer.call(:erledis, {:exists, key})
      false -> error_message
    end
  end

  @spec flushall :: boolean
  def flushall do
    GenServer.call(:erledis, :flushall)
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
      list -> map = Map.put(map, key, list ++ [value])
              {:reply, true, map}
       nil -> map = Map.put(map, key, [value])
              {:reply, true, map}
    end
  end

  def handle_call({:get, key}, _from, map) do
    case Map.get(map, key) do
      list -> {:reply, list, map}
       nil -> {:reply, [], map}
    end
  end

  def handle_call({:push, {key, value}}, _from,  map) do
    case Map.get(map, key) do
      list -> map = Map.put(map, key, list = [value | list])
              {:reply, list, map}
       nil -> map = Map.put(map, key, list = [value])
              {:reply, list, map}
    end
  end

  def handle_call({:pop, key}, _from,  map) do
    case Map.get(map, key) do
      list -> {last_value, list} = list |> List.pop_at(-1)
              map = Map.put(map, key, list)
              {:reply, last_value, map}
       nil -> {:reply, nil, map}
    end
  end

  def handle_call({:del, key}, _from, table) do
    case is_has_object(table, key) do
      true  -> :ets.delete(table, key)
               {:reply, true, table}
      false -> {:reply, false, table}
    end
  end

  def handle_call({:exists, key}, _from, table) do
    status = is_has_object(table, key)
    {:reply, status, table}
  end

  def handle_call(:flushall, _from, table) do
    status = :ets.delete_all_objects(table)
    {:reply, status, table}
  end
end
