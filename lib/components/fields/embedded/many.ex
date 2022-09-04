defmodule EctoLiveWeb.Components.Fields.Embedded.Many do
  use Phoenix.LiveComponent

  @impl true
  def update(%{value: [], type: {_, _, embedded}} = assigns, socket) do
    socket = assign(socket, Map.merge(assigns, %{type: {:array, embedded.related}}))

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)

    {:ok, socket}
  end
end
