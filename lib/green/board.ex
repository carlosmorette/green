defmodule Green.Board do
  @pieces ["n", "b", "w"]

  defguard exceeded_limit?(row, column) when row in [-1, 8] or column in [-1, 8]

  def make_board(), do: do_make_board(1, [])

  def do_make_board(9, acc), do: acc

  def do_make_board(4 = count, acc) do
    columns =
      Enum.map(1..8, fn
        4 -> "b"
        5 -> "w"
        _ -> "n"
      end)

    do_make_board(count + 1, acc ++ [columns])
  end

  def do_make_board(5 = count, acc) do
    columns =
      Enum.map(1..8, fn
        4 -> "w"
        5 -> "b"
        _ -> "n"
      end)

    do_make_board(count + 1, acc ++ [columns])
  end

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

  def traverse_lines(board, neighbors, {main_point, _player} = player_info) do
    board
    |> do_traverse_lines(neighbors, main_point, [], player_info)
    |> List.flatten()
  end

  def do_traverse_lines(_board, [], {_row, _column}, acc, _player_info), do: acc

  def do_traverse_lines(
        board,
        [{row_direction, columns_direction} | tail],
        {row, column},
        acc,
        player_info
      ) do
    result =
      do_traverse_columns(
        board,
        row_direction,
        columns_direction,
        {row, column},
        player_info,
        []
      )

    do_traverse_lines(board, tail, {row, column}, [result | acc], player_info)
  end

  def columns_add_acc(columns_direction) do
    Enum.map(columns_direction, fn direction -> {direction, []} end)
  end

  def do_traverse_columns(_board, _row_direction, [], {_row, _column}, _player_info, acc), do: acc

  def do_traverse_columns(
        board,
        row_direction,
        [column_direction | tail],
        {row, column},
        player_info,
        acc
      ) do
    result =
      do_traverse_column(board, row_direction, {column_direction, []}, {row, column}, player_info)

    do_traverse_columns(board, row_direction, tail, {row, column}, player_info, [result | acc])
  end

  def do_traverse_column(
        _board,
        _row_direction,
        {_column_direction, _acc},
        {row, column},
        _player_info
      )
      when exceeded_limit?(row, column),
      do: []

  def do_traverse_column(
        _board,
        _row_direction,
        {:stop, acc},
        {_row, _column},
        _player_info
      ),
      do: acc

  def do_traverse_column(
        board,
        row_direction,
        {column_direction, acc},
        {row, column},
        {_main_point, player} = player_info
      ) do
    vertical_movement =
      case row_direction do
        :up -> -1
        :same -> 0
        :down -> 1
      end

    horizontal_movement =
      case column_direction do
        :left -> -1
        :same -> 0
        :right -> 1
      end

    result = {row + vertical_movement, column + horizontal_movement}
    {row_place, column_place} = result

    place =
      board
      |> Enum.at(row_place)
      |> Enum.at(column_place)

    cond do
      place == player ->
        do_traverse_column(board, row_direction, {:stop, acc}, result, player_info)

      place == "n" ->
        do_traverse_column(board, row_direction, {:stop, []}, result, player_info)

      true ->
        do_traverse_column(
          board,
          row_direction,
          {column_direction, [result | acc]},
          result,
          player_info
        )
    end
  end
end
