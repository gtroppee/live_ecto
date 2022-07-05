defmodule EctoLiveWeb.Components.Fields.Map do
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
  def handle_event("add-as-string", _, %{assigns: %{value: value, new_name: name}} = socket) do
    socket = assign(socket, value: Map.merge(value, %{name => ""}))
    {:noreply, socket}
  end

  @impl true
  def handle_event("add-as-list", _, %{assigns: %{value: value, new_name: name}} = socket) do
    socket = assign(socket, value: Map.merge(value, %{name => [""]}))
    {:noreply, socket}
  end

  @impl true
  def handle_event("add-as-object", _, %{assigns: %{value: value, new_name: name}} = socket) do
    socket = assign(socket, value: Map.merge(value, %{name => %{}}))
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove", %{"name" => name}, %{assigns: %{value: value}} = socket) do
    socket = assign(socket, value: Map.delete(value, name))
    {:noreply, socket}
  end

  def type_for(value) when is_map(value) do
    :map
  end

  def type_for(value) when is_list(value) do
    {:array, :string}
  end

  def type_for(value) do
    :string
  end
end
