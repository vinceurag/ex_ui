defmodule ExUiTest do
  use ExUnit.Case
  doctest ExUi

  test "greets the world" do
    assert ExUi.hello() == :world
  end
end
