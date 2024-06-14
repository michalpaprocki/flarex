defmodule LightsOut.Supervisor do
  alias LightsOut.ProcessStore
  use Supervisor


  def start_link do
    Supervisor.start_link(__MODULE__, [], name: ProcessStore.Supervisor)
  end
  def init(_init_arg) do
    Supervisor.init([], strategy: :one_for_one)
  end
end
