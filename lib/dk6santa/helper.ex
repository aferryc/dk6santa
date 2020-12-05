defmodule Dk6santa.Helper do
  def spawn_func(func) when func |> is_function(), do: :erlang.spawn(func)
  def spawn_func(_func), do: nil

  def env(name) when name |> is_atom(), do: Application.get_env(:dk6santa, name)
  def env(_name), do: nil
end
