defmodule Green.Board do
  @pieces ["n", "b", "w"]

  defguard exceeded_limit?(row, column) when row in [-1, 8] or column in [-1, 8]

  def make_board(), do: do_make_board(1, [])

  def do_make_board(9, acc), do: acc

  def do_make_board(5 = count, acc) do
    columns =
      Enum.map(1..8, fn
        4 -> "b"
        5 -> "w"
        _ -> "n"
      end)

    do_make_board(count + 1, acc ++ [columns])
  end

  def do_make_board(4 = count, acc) do
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

  def make_moviment(board, player, {row, column}) do
    case have_movement?(board, player) do
      {_, false} ->
        {:same, board}

      {result, true} ->
        {_, {res, new_board}} =
          result
          |> Enum.filter(fn {{xrow, xcolumn}, _res} ->
            xrow == row and xcolumn == column
          end)
          |> List.first()

        case res do
          :same ->
            {:same, board}

          :changes ->
            {:changes, new_board}
        end
    end
  end

  def have_movement?(board, player) do
    result =
      board
      |> Enum.with_index()
      |> Enum.map(fn {row, index} ->
        row
        |> Enum.with_index()
        |> Enum.reduce([], fn {content, cindex}, acc ->
          if content == "n", do: [{index, cindex} | acc], else: acc
        end)
      end)
      |> List.flatten()
      |> Enum.reduce([], fn {row, column}, acc ->
        [{{row, column}, check_moviment(board, player, {row, column})} | acc]
      end)

    {result, Enum.any?(result, fn {_, {res, _new_boad}} -> res == :changes end)}
  end

  def check_moviment(board, player, {row, column}) do
    with {:ok, neighbors} <- find_neighbors(board, player, {row, column}),
         {:ok, pieces} <- traverse_lines(board, neighbors, {{row, column}, player}) do
      {:changes, swap_pieces(board, player, [{row, column} | pieces])}
    else
      :empty -> {:same, board}
      {:error, _error} -> {:error, board}
    end
  end

  def find_neighbors(board, player, {row, column}) do
    case Green.Neighbor.find_all(board, player, {row, column}) do
      {:error, :invalid_place} ->
        {:error, :invalid_place}

      [] ->
        :empty

      neighbors ->
        {:ok, neighbors}
    end
  end

  def traverse_lines(board, neighbors, {main_point, player}) do
    board
    |> do_traverse_lines(neighbors, main_point, [], player)
    |> List.flatten()
    |> case do
      [] ->
        :empty

      pieces ->
        {:ok, pieces}
    end
  end

  def do_traverse_lines(_board, [], {_row, _column}, acc, _player_info), do: acc

  def do_traverse_lines(
        board,
        [{direction, columns_direction} | tail],
        {row, column},
        acc,
        player
      ) do
    result =
      do_traverse_columns(
        board,
        direction,
        columns_direction,
        {row, column},
        player,
        []
      )

    do_traverse_lines(board, tail, {row, column}, [result | acc], player)
  end

  def do_traverse_columns(_board, _direction, [], {_row, _column}, _player, acc), do: acc

  def do_traverse_columns(
        board,
        direction,
        [column_direction | tail],
        {row, column},
        player,
        acc
      ) do
    result = do_traverse_column(board, direction, {column_direction, []}, {row, column}, player)

    do_traverse_columns(board, direction, tail, {row, column}, player, [result | acc])
  end

  def do_traverse_column(
        _board,
        _direction,
        {_column_direction, _acc},
        {row, column},
        _player
      )
      when exceeded_limit?(row, column),
      do: []

  def do_traverse_column(
        _board,
        _direction,
        {:stop, acc},
        {_row, _column},
        _player
      ),
      do: acc

  def do_traverse_column(
        board,
        direction,
        {column_direction, acc},
        {row, column},
        player
      ) do
    vertical_movement = vertical_movement(direction)
    horizontal_movement = horizontal_movement(column_direction)

    result = {row + vertical_movement, column + horizontal_movement}
    {row_place, column_place} = result

    place =
      case Enum.at(board, row_place) do
        nil -> nil
        row -> Enum.at(row, column_place)
      end

    cond do
      place == player ->
        do_traverse_column(board, direction, {:stop, acc}, result, player)

      place == "n" ->
        do_traverse_column(board, direction, {:stop, []}, result, player)

      true ->
        do_traverse_column(
          board,
          direction,
          {column_direction, [result | acc]},
          result,
          player
        )
    end
  end

  def vertical_movement(:up), do: -1
  def vertical_movement(:same), do: 0
  def vertical_movement(:down), do: 1

  def horizontal_movement(:left), do: -1
  def horizontal_movement(:same), do: 0
  def horizontal_movement(:right), do: 1

  def swap_pieces(new_board, _player, []), do: new_board

  def swap_pieces(board, player, [{row, column} | tail]) do
    new_row =
      board
      |> Enum.at(row)
      |> List.replace_at(column, player)

    new_board = List.replace_at(board, row, new_row)
    swap_pieces(new_board, player, tail)
  end
end
