defmodule PartpickerWeb.BuildLive.PhotoUpload do
  use PartpickerWeb, :live_view

  alias Partpicker.{Builds, Builds.Photo}

  @impl true
  def mount(%{"id" => id}, %{"user_token" => user_token}, socket) do
    case Partpicker.Accounts.get_user_by_session_token(user_token) do
      nil ->
        {:error, socket}

      user ->
        build = Builds.get_build!(user, id)

        {:ok,
         socket
         |> assign(:user, user)
         |> assign(:build, build)
         |> assign(:changeset, Builds.change_build(build))
         |> allow_upload(:photos,
           accept: ~w(.png .jpg .jpeg),
           max_entries: 10,
           auto_upload: true,
           progress: &handle_progress/3
         )}
    end
  end

  @impl true
  def handle_cast({:create_photo, entry}, socket) do
    photo = %Photo{build_id: socket.assigns.build.id}
    upload_path = Photo.upload_path!(photo, entry)

    changeset =
      Photo.changeset(photo, %{
        path: upload_path,
        mime: entry.client_type,
        filename: entry.client_name
      })

    Partpicker.Repo.insert!(changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    case uploaded_entries(socket, :photos) do
      {_, [%{valid?: false, client_name: name}]} ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "File must be .jpg or .png extension. Got #{Path.extname(name)}"
         )}

      _ ->
        {:noreply, socket}
    end
  end

  defp handle_progress(:photos, entry, socket) do
    socket =
      if entry.done?,
        do:
          consume_uploaded_entry(socket, entry, &consume_uploaded_image(socket, &1.path, entry)),
        else: socket

    {:noreply, socket}
  end

  defp consume_uploaded_image(socket, path, entry) do
    upload_path = Photo.upload_path!(%Photo{build_id: socket.assigns.build.id}, entry)
    :ok = File.cp!(path, upload_path)
    GenServer.cast(socket.root_pid, {:create_photo, entry})
    socket
  end
end
