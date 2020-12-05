defmodule Dk6santa.Helper do
  def spawn_func(func) when func |> is_function(), do: :erlang.spawn(func)
  def spawn_func(_func), do: nil

  def env(name) when name |> is_atom(), do: Application.get_env(:dk6santa, name)
  def env(_name), do: nil

  def zipped_derangement(list) when list |> is_list() do
    cond do
      Enum.count(list) == 1 ->
        nil

      list -- Enum.uniq(list) != [] ->
        nil

      Enum.count(list) == 2 ->
        list2 = list |> Enum.reverse()
        Enum.zip(list, list2)

      true ->
        list2 = list |> Enum.shuffle()
        new_list = check_derangement_validity(list, list2)
        new_list
    end
  end

  def derangement(_list), do: []

  defp check_derangement_validity(list, list2) do
    zip_list = Enum.zip(list, list2)
    bad_arrangement = zip_list |> Enum.filter(fn {original, shuffled} -> original == shuffled end)
    good_arrangement = zip_list -- bad_arrangement

    cond do
      Enum.count(bad_arrangement) == 1 ->
        # Redo from scratch
        Dk6santa.Helper.zipped_derangement(list)

      Enum.count(bad_arrangement) >= 2 ->
        {bad_list, _shuffled} = bad_arrangement |> Enum.unzip()
        new_arrangement = Dk6santa.Helper.zipped_derangement(bad_list)
        good_arrangement ++ new_arrangement

      Enum.count(bad_arrangement) < 1 ->
        good_arrangement
    end
  end
end
