defmodule EctoLiveWeb.Form do
  use EctoLiveWeb.Base

  @impl true
  def update(%{schema: schema, resource: resource} = assigns, socket) do
    {:ok, socket} = super(assigns, socket)

    socket = assign(socket,
      attributes: Helpers.attributes(schema),
      resource: resource,
      changeset: schema.changeset(resource, %{})
    )

    {:ok, socket}
  end

  @impl true
  def handle_event("action", params, %{assigns: %{action: action, resource: resource, schema: schema}} = socket) do
    params = params |> Map.get(schema.__schema__(:source) |> Inflex.singularize)
    changeset = schema.changeset(resource, params)
    socket = run_action(action, changeset, socket)

    {:noreply, socket}
  end
end
