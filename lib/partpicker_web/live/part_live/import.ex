defmodule PartpickerWeb.PartLive.Import do
  use PartpickerWeb, :live_view

  alias Partpicker.{
    Builds
  }

  alias NimbleCSV.RFC4180, as: CSV
  @import_limit 1000

  @impl true
  def mount(%{"build" => build_id}, _session, socket) do
    build = Builds.get_build!(build_id)

    {:ok,
     socket
     |> assign(:build, build)
     |> assign(:changeset, Builds.change_build(build, %{}))
     |> assign(:results, [])
     |> allow_upload(:csv,
       accept: ~w(.csv .txt),
       max_entries: 1,
       auto_upload: true,
       progress: &handle_progress/3
     )}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    case uploaded_entries(socket, :csv) do
      {_, [%{valid?: false, client_name: name}]} ->
        {:noreply,
         put_flash(socket, :error, "File must be .csv extension. Got #{Path.extname(name)}")}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("delete", %{"line" => line}, socket) do
    line_num = String.to_integer(line)
    results = Enum.reject(socket.assigns.results, &match?({^line_num, _}, &1))
    {:noreply, assign(socket, results: results)}
  end

  def handle_event("import_single", %{"line" => line}, socket) do
    line_num = String.to_integer(line)

    results =
      Enum.find(socket.assigns.results, &match?({^line_num, _}, &1))
      |> do_import()
      |> handle_import_result(line_num, socket.assigns.results)

    {:noreply, assign(socket, results: results)}
  end

  def handle_event("import_all", %{}, socket) do
    for line = {ln, _} <- socket.assigns.results do
      GenServer.cast(socket.root_pid, {:import_result, ln, do_import(line)})
    end

    {:noreply, socket}
  end

  @impl true
  def handle_cast({:parse_line, line_number, line}, socket) do
    changeset = Builds.parse_part(%Builds.Part{build_id: socket.assigns.build.id}, line)
    result = {line_number, changeset}
    {:noreply, update(socket, :results, &sort_results([result | &1]))}
  end

  def handle_cast({:import_result, line_num, result}, socket) do
    {:noreply, update(socket, :results, &handle_import_result(result, line_num, &1))}
  end

  defp do_import({_, changeset}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert_or_update(:part, changeset)
    |> Partpicker.Repo.transaction()
  end

  defp handle_import_result(result, line_num, results) do
    case result do
      {:ok, _} ->
        Enum.reject(results, &match?({^line_num, _}, &1))

      {:error, :part, changeset, _} ->
        Enum.map(results, &maybe_update_changeset(&1, line_num, changeset))
    end
  end

  defp maybe_update_changeset({line_num, _c}, line_num, changeset) do
    {line_num, changeset}
  end

  defp maybe_update_changeset(line, _, _), do: line

  defp handle_progress(:csv, entry, socket) do
    socket =
      if entry.done?,
        do: consume_uploaded_entry(socket, entry, &parse_csv(socket, &1.path)),
        else: socket

    {:noreply, socket}
  end

  defp parse_csv(socket, path) do
    File.read!(path)
    |> CSV.parse_string(skip_headers: false)
    |> case do
      [_header | rest] when length(rest) <= @import_limit ->
        for {line, line_num} <- Enum.with_index(rest, 1) do
          GenServer.cast(socket.root_pid, {:parse_line, line_num, line})
        end

        socket

      [_header | rest] ->
        put_flash(socket, :error, "CSV exceeds 1000 line import limit - Got: #{length(rest)}")

      _bad ->
        put_flash(socket, :error, "Malformed CSV headers")
    end
  end

  defp sort_results(results) do
    # Line number is first element of tuple
    Enum.sort_by(results, &elem(&1, 0))
  end
end
