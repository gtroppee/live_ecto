defmodule EctoLiveWeb.Components.Fields.Id do
  use Phoenix.LiveComponent
  alias EctoLive.Helpers

  @impl true
  def update(%{name: name, schema: schema} = assigns, socket) do
    socket = assign(
      socket,
      Map.merge(assigns, %{association: association_for(name, schema)})
    )
    {:ok, socket}
  end

  def association_for(name, schema) do
    case String.contains?(name, "[id]") do
      true ->
        nil
      _ ->
        parent_name =
          Regex.run(~r/(?<=\[).+?(?=\])/, name)
          |> List.first

        Helpers.parent_associations(schema)
        |> Enum.find(fn association -> "#{association.owner_key}" == parent_name end)
    end
  end
end
