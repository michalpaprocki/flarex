defmodule LightsOutTest do
  alias LightsOut.ProcessStore
  use ExUnit.Case
  doctest LightsOut

    test "pings a genserver" do
      assert ProcessStore.ping() == :pong
    end

    test "adds a tuple to an :ets table" do
      assert ProcessStore.add_ref(self(), :custom_ref) == true
    end

    test "retrieves a tuple from an :ets table" do
      ProcessStore.add_ref(self(), :custom_ref)
      assert ProcessStore.get_ref(self()) == [[:custom_ref]]
    end
    test "removes a tuple from an :ets table" do
      ProcessStore.add_ref(self(), :custom_ref)
      assert  ProcessStore.delete_ref(self()) == true
    end
  end
