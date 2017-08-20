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

  @spec unshift(String.t(), any) :: list
  def unshift(key, value) do
    case is_binary(key) do
      true  -> GenServer.call(:erledis, {:unshift, {key, value}})
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

  @spec is_has_object(atom, String.t()) :: boolean
  defp is_has_object(table, key) do
    case :ets.lookup(table, key) do
      [] -> false
       _ -> true
    end
  end

  defp error_message do
    "key argument must be a string"
  end

  # CALLBACKS

  def init(table) do
    t_name = :ets.new(table, [:set, :protected])
    {:ok, t_name}
  end

  def handle_call({:set, {key, value}}, _from,  table) do
    case :ets.lookup(table, key) do
      [{_key, list}|_] -> status = :ets.insert(table, {key, list ++ [value]})
                          {:reply, status, table}
                    [] -> status = :ets.insert(table, {key, [value]})
                          {:reply, status, table}
    end
  end

  def handle_call({:get, key}, _from, table) do
    case :ets.lookup(table, key) do
      [{_key, value}|_] -> {:reply, value, table}
                     [] -> {:reply, [], table}
    end
  end

  def handle_call({:unshift, {key, value}}, _from,  table) do
    case :ets.lookup(table, key) do
      [{_key, list}|_] -> :ets.insert(table, {key, list = [value | list]})
                          {:reply, list, table}
                    [] -> status = :ets.insert(table, {key, list = [value]})
                          {:reply, list, table}
    end
  end

  def handle_call({:pop, key}, _from,  table) do
    case :ets.lookup(table, key) do
      [{_key, list}|_] -> {last_value, list} = list |> List.pop_at(-1)
                          :ets.insert(table, {key, list})
                          {:reply, last_value, table}
                    [] -> {:reply, nil, table}
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
