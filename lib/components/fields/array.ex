defmodule EctoLiveWeb.Components.Fields.Array do
  use Phoenix.LiveComponent

  @impl true
  def mount(socket) do
    socket = assign(socket, new_name: "")
    {:ok, socket}
  end

  @impl true
  def handle_event("set-name", params, socket) do
    {_, name} = params |> Enum.to_list |> List.last
    socket = assign(socket, new_name: name)
    {:noreply, socket}
  end

  @impl true
  def handle_event("add-as-string", _, %{assigns: %{value: value, new_name: new_name}} = socket) do
    socket = assign(socket, value: List.insert_at(value, -1, new_name))
    {:noreply, socket}
  end

  @impl true
  def handle_event("add-as-list", _, %{assigns: %{value: value, new_name: new_name}} = socket) do
    socket = assign(socket, value: List.insert_at(value, -1, [new_name]))
    {:noreply, socket}
  end

  @impl true
  def handle_event("add-as-object", _, %{assigns: %{value: value, new_name: new_name}} = socket) do
    socket = assign(socket, value: List.insert_at(value, -1, %{new_name => ""}))
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove", %{"index" => index}, %{assigns: %{value: value}} = socket) do
    socket = assign(socket, value: List.delete_at(value, String.to_integer(index)))
    {:noreply, socket}
  end
end
