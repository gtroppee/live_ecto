defmodule EctoLiveWeb.List do
  use EctoLiveWeb.Base
  alias EctoLive.Helpers
  alias Phoenix.LiveView.JS
  import Ecto.Query, only: [where: 2]

  @impl true
  def update(%{schema: schema} = assigns, socket) do
    {:ok, socket} = super(assigns, socket)

    default_filters = []

    socket = assign(socket,
      attributes: Helpers.attributes_without_fkeys(schema),
      resources: resources_for_filters(schema, default_filters),
      parent_associations: Helpers.parent_associations(schema),
      filters: default_filters
    )

    {:ok, socket}
  end

  def resources_for_filters(schema, filters) do
    schema
    |> where(^filters)
    |> Helpers.repo().all
  end

  @impl true
  def handle_event("action", %{"name" => name, "id" => id}, %{assigns: %{schema: schema, actions: actions, resources: resources}} = socket) do
    action = Enum.find(actions, fn {n, _} -> Atom.to_string(n) == name end)
    resource = Enum.find(resources, fn r -> "#{Helpers.resource_id(r)}" == "#{id}" end)
    changeset = schema.changeset(resource, %{})
    changeset = Helpers.declare_fkey_constraints(schema, changeset)

    socket = run_action(action, changeset, socket)

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter", params, %{assigns: %{schema: schema}} = socket) do
    params =
      params
      |> Map.new(fn {key, value} -> {String.to_atom(key), value} end)
      |> Enum.filter(fn {_, value} -> value != "" end)

    socket = assign(socket, resources: resources_for_filters(schema, params), filters: params)

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear-filters", _, %{assigns: %{schema: schema}} = socket) do
    socket = assign(socket, resources: resources_for_filters(schema, []), filters: [])

    {:noreply, socket}
  end

  def show_dropdown(type, resource_id, js \\ %JS{}) do
    js
    |> JS.add_class("show", to: "#dropdown-#{type}-#{resource_id}")
  end

  def hide_dropdown(type, resource_id, js \\ %JS{}) do
    js
    |> JS.remove_class("show", to: "#dropdown-#{type}-#{resource_id}")
  end
end
