defmodule AshStudioWeb.DiagramController do
  use AshStudioWeb, :controller

  def show(conn, %{"filename" => filename}) do
    show(conn, filename, Path.extname(filename))
  end

  defp show(conn, filename, ".svg") do
    if File.exists?(filename) do
      conn
      |> put_resp_content_type("image/svg+xml")
      |> send_file(200, filename)
    else
      send_resp(conn, 404, "SVG not found")
    end
  end

  defp show(conn, filename, ".png") do
    if File.exists?(filename) do
      conn
      |> put_resp_content_type("image/png")
      |> send_file(200, filename)
    else
      send_resp(conn, 404, "PNG not found")
    end
  end

  defp show(conn, _, _ext) do
    send_resp(conn, 404, "UNSUPPORTED Diagram file type or File not found")
  end
end
