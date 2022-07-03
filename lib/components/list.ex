defmodule EctoLiveWeb.List do
  use EctoLiveWeb.Base
  alias EctoLive.Helpers

  @impl true
  def update(%{schema: schema} = assigns, socket) do
    {:ok, socket} = super(assigns, socket)

    socket = assign(socket,
      resources: Helpers.repo().all(schema)
    )

    {:ok, socket}
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
end
