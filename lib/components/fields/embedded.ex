defmodule EctoLiveWeb.Components.Fields.Embedded do
  use Phoenix.LiveComponent
  alias EctoLive.Helpers

  @impl true
  def update(%{type: {_, _, embedded}} = assigns, socket) do
    socket = assign(socket,
      Map.merge(assigns, %{fields: Helpers.fields(embedded.related)})
    )
    {:ok, socket}
  end
end
