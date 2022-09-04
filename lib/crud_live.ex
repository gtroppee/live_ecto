defmodule EctoLiveWeb.CRUDLive do
  use EctoLiveWeb.BaseLive

  def actions(:index) do
    [{:delete, fn (resource) -> Helpers.repo().delete(resource) end}]
  end

  def actions(:new) do
    [{:insert, fn (changeset) -> Helpers.repo().insert(changeset) end}]
  end

  def actions(:edit) do
    [{
      :update,
      fn (changeset) ->
        Helpers.repo().update(changeset)
      end
    }]
  end

  def internal_links(%{resource_name: resource_name, socket: socket} = assigns) do
    [edit_link(assigns) | new_child_links(assigns)]
  end

  def external_links(%{resource_name: resource_name, socket: socket} = assigns) do
    Helpers.links()[resource_name] || []
  end

  defp edit_link(%{resource_name: resource_name, socket: socket}) do
    {
      :edit,
      fn (socket, resource) ->
        Helpers.routes().crud_path(socket, :edit, resource_name, Helpers.resource_id(resource))
      end
    }
  end

  defp new_child_links(%{schema: schema, socket: socket}) do
    Enum.map(Helpers.child_associations(schema), fn association ->
      {
        :"new_#{association.field |> Inflex.singularize}",
        fn (socket, resource) ->
          Helpers.routes().crud_path(socket, :new, association.field, %{association.related_key => Helpers.resource_id(resource)})
        end
      }
    end)
  end
end
