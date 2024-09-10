defmodule AlphaTest do
  use ExUnit.Case
  doctest Alpha

  test "greets the world" do
    assert Alpha.hello() == :world
  end
end
