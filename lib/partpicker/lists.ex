defmodule Partpicker.Lists do
  alias Partpicker.{
          Repo,
          List,
          List.Part,
          List.Selection
        },
        warn: false

  import Ecto.Query, warn: false

  def find_list_by_tag(tag) do
    Repo.one(from l in List, where: l.tag == ^tag)
    |> Repo.preload(parts: :selection)
  end

  def find_cached_list(tag) do
    case :ets.lookup(:partpicker_lists, tag) do
      [{^tag, changeset}] -> changeset
      _ -> nil
    end
  end

  def cache_list(changeset) do
    tag = Ecto.Changeset.get_field(changeset, :tag) || raise ArgumentError
    :ets.insert(:partpicker_lists, {tag, changeset})
  end

  def change_list(list, attrs \\ %{}) do
    List.changeset(list, attrs)
  end

  def new_selection(attrs) do
    %Selection{}
    |> change_selection(attrs)
    |> Repo.insert()
  end

  def change_selection(selection, attrs \\ %{}) do
    Selection.changeset(selection, attrs)
  end

  def selection_for_tag(tag) do
    Repo.all(from s in Selection, where: ^tag in s.tags)
  end
end
