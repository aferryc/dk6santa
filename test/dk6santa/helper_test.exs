defmodule Dk6santa.HelperTest do
  use ExUnit.Case

  test "zipped_derangement/1 always return valid derangement" do
    assert Dk6santa.Helper.zipped_derangement([1]) |> is_nil()

    assert Dk6santa.Helper.zipped_derangement([67, 12, 1234, 2346, 34567, 346, 1, 2])
           |> is_valid_derangement?

    assert Dk6santa.Helper.zipped_derangement([12, 12, 13, 13, 15, 15, 16, 16, 17, 17])
           |> is_nil()

    assert Dk6santa.Helper.zipped_derangement([1, 2]) |> is_valid_derangement?
  end

  defp is_valid_derangement?(result) when result |> is_list() do
    result
    |> Enum.all?(fn {original, shuffled} ->
      original != shuffled
    end)
  end
end
