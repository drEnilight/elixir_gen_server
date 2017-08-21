defmodule Erledis.Supervisor do
  use Supervisor

  def start_link(name) do
    Supervisor.start_link(__MODULE__, [], name: name)
  end

  def init(_) do
    children = [
      worker(Erledis, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
