defmodule Erledis.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], __MODULE__)
  end

  def init(_) do
    children = [
      worker(Erledis, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
