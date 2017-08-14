defmodule Erledis do
  use GenServer
  require IEx

  # API

  def start_link do
    GenServer.start_link(__MODULE__, :erledis, name: :erledis)
  end

  @spec set(String.t(), any) :: boolean
  def set(key, value) do
    GenServer.cast(:erledis, {:set, {key, value}})
  end

  @spec get(String.t()) :: any
  def get do
    GenServer.call(:erledis, :get)
  end

  # SERVER

  def init(table) do
    table = :ets.new(table, [:set, :protected])
    {:ok, table}
  end

  def handle_cast({:set, message}, table) do
    case :ets.insert(table, message) do
      true  -> {:noreply, true}
      false -> {:noreply, false}
    end
  end

  def handle_call(:get, _from, table) do
    {:reply, true}
  end
end
