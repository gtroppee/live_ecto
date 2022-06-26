defmodule EctoLiveWeb.Form do
  use EctoLiveWeb.Base

  @impl true
  def update(%{schema: schema, resource: resource} = assigns, socket) do
    {:ok, socket} = super(assigns, socket)

    socket = assign(socket,
      resource: resource,
      changeset: schema.changeset(resource, %{})
    )

    {:ok, socket}
  end

  @impl true
  def handle_event("action", %{"name" => name}, %{assigns: %{actions: actions, changeset: changeset}} = socket) do
    action = Enum.find(actions, fn {n, _} -> Atom.to_string(n) == name end)
    socket = run_action(action, changeset, socket)

    {:noreply, socket}
  end
end
