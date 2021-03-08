defmodule PartpickerWeb.PartLive.Import do
  use PartpickerWeb, :live_view

  alias Partpicker.{
    Builds,
    Builds.Part.ImportJob
  }

  @impl true
  def mount(%{"import_job" => uuid}, _session, socket) do
    {:ok, socket}
  end

  def mount(%{"build" => build_id}, _session, socket) do
    build = Builds.get_build!(build_id)
    import_job = %ImportJob{build_id: build.id}

    {:ok,
     socket
     |> assign(:import_job, import_job)
     |> assign(:changeset, Builds.change_part_import(import_job))
     |> assign(:uploaded_files, [])
     |> allow_upload(:csv, accept: ~w(.csv .txt), max_entries: 1)}
  end

  @impl true

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    [path] =
      consume_uploaded_entries(socket, :csv, fn %{path: path}, entry ->
        path
      end)

    changeset = Builds.change_part_import(socket.assigns.import_job, %{path: path})

    case Partpicker.Repo.insert(changeset) do
      {:ok, import_job} ->
        {:noreply,
         socket
         |> push_redirect(to: Routes.part_import_status_path(socket, :import_status, import_job))}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)}
    end
  end
end
