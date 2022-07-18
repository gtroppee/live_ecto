defmodule EctoLiveWeb.CRUDLive do
  use EctoLiveWeb.BaseLive

  def actions(:index) do
    [{:delete, fn (resource) -> Helpers.repo().delete(resource) end}]
  end

  def actions(:new) do
    [{:insert, fn (changeset) -> Helpers.repo().insert(changeset) end}]
  end

  def actions(:edit) do
    [{:update, fn (changeset) -> Helpers.repo().update(changeset) end}]
  end

  def links(assigns) do
    [edit_link(assigns) | new_child_links(assigns)]
  end

  defp edit_link(%{resource_name: resource_name, socket: socket}) do
    {
      :edit,
      fn (resource) ->
        Helpers.routes().crud_path(socket, :edit, resource_name, resource.id)
      end
    }
  end

  defp new_child_links(%{schema: schema, socket: socket}) do
    Enum.map(Helpers.child_associations(schema), fn association ->
      {
        :"new_#{association.field |> Inflex.singularize}",
        fn (resource) ->
          Helpers.routes().crud_path(socket, :new, association.field, %{association.related_key => resource.id})
        end
      }
    end)
  end
end
