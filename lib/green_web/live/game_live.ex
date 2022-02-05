defmodule GreenWeb.GameLive do
  use Phoenix.LiveView

  alias Green.Board

  def mount(_params, _session, socket) do
    if connected?(socket) do
      board = Green.Board.make_board()

      {:ok, assign(socket, board: board, player: "b")}
    else
      {:ok, assign(socket, page: "loading")}
    end
  end

  def render(%{page: "loading"} = assigns) do
    ~H"""
    <h2>Loading...</h2>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="game-container">
      <p class="turn"><%= if @player == "b", do: "Black", else: "White"%></p>
      <%= for {row, index} <- Enum.with_index(@board) do %>
        <div class="flex">

          <%= for {content, column} <- Enum.with_index(row) do %>
            <div class="square fill">
              <%= render_place(assigns, {{index, column}, content}) %>
            </div>
          <% end %>

        </div>
      <% end %>
    </div>
    """
  end

  def render_place(assigns, {{_row, _column}, "w"}) do
    ~H"""
    <div class="piece white"></div>
    """
  end

  def render_place(assigns, {{_row, _column}, "b"}) do
    ~H"""
    <div class="piece black"></div>
    """
  end

  def render_place(assigns, {{row, column}, "n"}) do
    ~H"""
    <div class="null" phx-click="make-play" phx-value-row={row} phx-value-column={column}></div>
    """
  end

  def handle_event("make-play", %{"row" => row, "column" => column}, socket) do
    {row, column} = {String.to_integer(row), String.to_integer(column)}
    board = socket.assigns.board
    player = socket.assigns.player

    socket =
      case Board.make_moviment(board, player, {row, column}) do
        {:same, _board} ->
          socket

        {:changes, new_board} ->
          another_player = get_another_player(player)

          case Board.have_movement?(new_board, another_player) do
            {_result, true} ->
              socket
              |> update(:board, fn _ -> new_board end)
              |> update(:player, fn _ -> another_player end)

            {_result, false} ->
              update(socket, :board, fn _ -> new_board end)
          end
      end

    {:noreply, socket}
  end

  def get_another_player("b"), do: "w"

  def get_another_player("w"), do: "b"
end
