defmodule Flarex.ProcessStore do

  use GenServer
@moduledoc """
  A GenServer wrapper around :ets store responsible for holding process references.
"""
  @name __MODULE__
@doc """
  Starts a GenServer process.
"""
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: @name)
  end
  def ping do
    GenServer.call(@name, :ping)
  end
  def init(_init_arg) do

    :ets.new(:refs, [:protected, :named_table, :set])
    {:ok, :ok}
  end
  @doc """
    Adds a record to the :ets table.

    ## Examples

        Flarex.ProcessStore.add_ref(exisiting_pid, ref)
        true

        Flarex.ProcessStor.add_ref("not_a_valid_pid" ref)
        true

        Flarex.ProcessStor.add_ref(self(), :not_a_valid_ref)
        true

  """
  def add_ref(pid, ref) do
    GenServer.call(@name, {:add, pid, ref})
  end
  @doc """
    Retrieves a record from the :ets table.

    ## Examples

        Flarex.ProcessStor.get_ref(existing_pid)
        [[ref]]
        Flarex.ProcessStor.get_ref(non-existent_pid)
        []

  """
  def get_ref(pid) do
    GenServer.call(@name, {:get, pid})
  end
    @doc """
    Removes a record from the :ets table.

    ## Examples

        ClearFlasg.ProcessStor.delete_ref(existing_pid)
        true
        ClearFlasg.ProcessStor.delete_ref(non-existent_pid)
        true

  """
  def delete_ref(pid) do
    GenServer.call(@name, {:delete, pid})
  end
  def get_store() do
    GenServer.call(@name, :get_all)
  end
# # # # # # # # # # # # # # # # handlers  # # # # # # # # # # # # # # # #
def handle_call(:ping, _from, state) do

  {:reply, :pong, state}
end
  def handle_call({:add, pid, ref}, _from, state) do
    resp = :ets.insert(:refs_test, {pid, ref})
    {:reply, resp, state}
  end

  def handle_call({:get, pid}, _from, state) do

    ref = :ets.match(:refs_test, {pid, :"$1"})

    {:reply, ref, state}
  end

  def handle_call({:delete, pid}, _from, state) do

    ref = :ets.delete(:refs_test, pid)

    {:reply, ref, state}
  end

  def handle_call(:get_all, _from, state) do

    refs = :ets.match(:refs_test, {:"$0", :"$1"})

    {:reply, refs, state}
  end
end
