defmodule GreenWeb.PageController do
  use GreenWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
