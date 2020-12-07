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
        shuffled_list = list |> Enum.shuffle()
        [head | tail] = shuffled_list
        derangement_list = tail ++ [head]
        Enum.zip(shuffled_list, derangement_list)
    end
  end
end
