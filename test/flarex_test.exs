defmodule FlarexTest do
  use ExUnit.Case
  doctest Flarex

  test "greets the world" do
    assert Flarex.hello() == :world
  end
end
