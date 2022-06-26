defmodule EctoLiveWeb.Components.Fields.Smart do
  use Phoenix.LiveComponent

  @impl true
  def update(%{name: name} = assigns, socket) do
    socket = assign(socket,
      Map.merge(assigns, %{label_name: label_name(name)})
    )
    {:ok, socket}
  end

  def label_name(name) do
    Regex.scan(~r/\[(.*?)\]/, name)
    |> List.last
    |> List.last
  end
end
