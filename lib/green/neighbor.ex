defmodule Green.Neighbor do
  @players ["w", "b"]

  def find_all(board, player, {row, column}) when player in @players do
    board
    |> Enum.at(row)
    |> Enum.at(column)
    |> is_empty?()
    |> if do
      board
      |> get_by_row(row)
      |> get_by_column(column)
      |> filter_valid(player)
      |> remove_empty()
    else
      {:error, :invalid_place}
    end
  end

  def is_empty?("n"), do: true

  def is_empty?(_), do: false

  def get_by_row(board, row) do
    row
    |> rows()
    |> Enum.reduce([], fn {direction, n}, acc ->
      [{direction, Enum.at(board, row + n)} | acc]
    end)
  end

  def rows(0), do: [{:down, 1}, {:same, 0}]

  def rows(7), do: [{:up, -1}, {:same, 0}]

  def rows(_place_row), do: [{:up, -1}, {:same, 0}, {:down, 1}]

  def get_by_column(rows, column), do: do_get_by_column(rows, column, [])

  def do_get_by_column([], _column, acc), do: acc

  def do_get_by_column([{position, row} | tail], column, acc) do
    result =
      column
      |> columns()
      |> Enum.reduce([], fn
        {:same, index}, acc ->
          if position == :same, do: acc, else: [{:same, Enum.at(row, column + index)} | acc]

        {direction, index}, acc ->
          [{direction, Enum.at(row, column + index)} | acc]
      end)

    do_get_by_column(tail, column, [{position, result} | acc])
  end

  def columns(0), do: [{:right, 1}, {:same, 0}]

  def columns(7), do: [{:left, -1}, {:same, 0}]

  def columns(_column), do: [{:left, -1}, {:same, 0}, {:right, 1}]

  def filter_valid(rows, player), do: do_filter(rows, player, [])

  def do_filter([], _player, acc), do: acc

  def do_filter([{position, row} | tail], player, acc) do
    filtered =
      row
      |> Enum.filter(fn {_direction, n} -> n != player and n != "n" end)
      |> Enum.map(fn {direction, _n} -> direction end)

    do_filter(tail, player, [{position, filtered} | acc])
  end

  def remove_empty(neighbors) do
    Enum.filter(neighbors, fn {_direction, neigh} -> not Enum.empty?(neigh) end)
  end
end
