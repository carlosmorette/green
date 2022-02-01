defmodule Green.Board do
  @pieces ["n", "b", "w"]

  def make_board(), do: do_make_board(1, [])

  def do_make_board(9, acc), do: acc

  def do_make_board(count, acc) do
    do_make_board(count + 1, acc ++ [Enum.map(1..8, fn _ -> "n" end)])
  end

  def make_random_board(), do: do_make_random_board(1, [])

  def do_make_random_board(9, acc), do: acc

  def do_make_random_board(count, acc) do
    do_make_random_board(count + 1, acc ++ [Enum.map(1..8, fn _ -> Enum.random(@pieces) end)])
  end

  def find_neighbors(board, player, {row, column}) do
    Green.Neighbor.find_all(board, player, {row, column})
  end
end
