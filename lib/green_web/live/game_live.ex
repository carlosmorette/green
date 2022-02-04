defmodule GreenWeb.GameLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    if connected?(socket) do
      board = Green.Board.make_board()
      {:ok, assign(socket, board: board)}
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
    <div class="null" phx-click="put" phx-value-row={row} phx-value-column={column}></div>
    """
  end

  def handle_event("put", %{"row" => row, "column" => column}, socket) do
    # {row, column} = {String.to_integer(row), String.to_integer(column)}
    {:noreply, socket}
  end
end
