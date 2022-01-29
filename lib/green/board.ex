defmodule Green.Board do
  def make_board(), do: do_make_board(1, [])

  def do_make_board(9, acc), do: acc

  def do_make_board(4 = count, acc) do
    new_row =
      1..8
      |> Enum.map(fn n -> 
        cond do
          n == 4 -> 
            {n, "b"}

          n == 5 ->
            {n, "w"}

          true ->
            {n, "n"}
        end
      end)
      |> Kernel.++([count])

    do_make_board(count + 1, acc ++ [new_row])
  end

  def do_make_board(5 = count, acc) do
    new_row =
      1..8
      |> Enum.map(fn n -> 
        cond do
          n == 4 -> 
            {n, "w"}

          n == 5 ->
            {n, "b"}

          true ->
            {n, "n"}
        end
      end)
      |> Kernel.++([count])

    do_make_board(count + 1, acc ++ [new_row])
  end

  def do_make_board(count, acc) do
    new_row = 
      1..8
      |> Enum.map(fn n -> {n, "n"} end)
      |> Kernel.++([count])

    do_make_board(count + 1, acc ++ [new_row])
  end
end
