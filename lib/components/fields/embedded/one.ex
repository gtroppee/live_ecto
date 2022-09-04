defmodule EctoLiveWeb.Components.Fields.Embedded.One do
  use Phoenix.LiveComponent

  @impl true
  def update(%{type: {_, _, embedded}} = assigns, socket) do
    socket = assign(socket, Map.merge(assigns, %{value: embedded.related}))

    {:ok, socket}
  end
end
