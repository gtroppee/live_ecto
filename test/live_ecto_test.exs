defmodule LiveEctoTest do
  use ExUnit.Case
  doctest LiveEcto

  test "greets the world" do
    assert LiveEcto.hello() == :world
  end
end
