defmodule EctoLiveWeb.Components.Fields.Struct do
  use Phoenix.LiveComponent
  alias EctoLive.Helpers

  @impl true
  def update(%{value: struct} = assigns, socket) do
    socket = assign(socket,
      Map.merge(assigns, %{fields: Helpers.fields(struct.__struct__)})
    )
    {:ok, socket}
  end
end
