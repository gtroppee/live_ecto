defmodule EctoLiveWeb.List do
  use EctoLiveWeb.Base
  alias EctoLive.Helpers
  import Ecto.Query, only: [where: 2]

  @impl true
  def update(%{schema: schema} = assigns, socket) do
    {:ok, socket} = super(assigns, socket)

    default_filters = []

    socket = assign(socket,
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
    resource = Enum.find(resources, fn r -> r.id == String.to_integer(id) end)
    changeset = schema.changeset(resource, %{})
    changeset = Helpers.declare_fkey_constraints(schema, changeset)

    socket = run_action(action, changeset, socket)

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter", params, %{assigns: %{schema: schema}} = socket) do
    params =
      params
      |> Map.Helpers.atomize_keys
      |> Enum.filter(fn {_, value} -> value != "" end)

    socket = assign(socket, resources: resources_for_filters(schema, params), filters: params)

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear-filters", _, %{assigns: %{schema: schema}} = socket) do
    socket = assign(socket, resources: resources_for_filters(schema, []), filters: [])

    {:noreply, socket}
  end
end
