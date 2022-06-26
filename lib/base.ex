defmodule EctoLiveWeb.Base do
  defmacro __using__(_) do
    quote do
      use Phoenix.LiveComponent
      alias EctoLive.Helpers

      @impl true
      def update(%{schema: schema} = assigns, socket) do
        socket = assign(socket,
          schema: schema,
          attributes: Helpers.attributes(schema),
          actions: Map.get(assigns, :actions, []),
          links: Map.get(assigns, :links, [])
        )

        {:ok, socket}
      end

      def handle_event("update-changeset", params, %{assigns: %{schema: schema, changeset: changeset}} = socket) do
        params = params |> Map.get(schema.__schema__(:source) |> Inflex.singularize)
        changeset = schema.changeset(changeset.data, params)

        {:noreply, assign(socket, changeset: changeset)}
      end

      defp run_action({name, function}, changeset, socket) do
        case function.(changeset) do
          {:ok, data} ->
            send(self(), {:ok, {:action, name, data}})
            socket

          {:error, %Ecto.Changeset{} = changeset} ->
            d = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
              Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
                opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
              end)
            end)
            send(self(), {:error, {:action, name, "#{d |> Jason.encode!}"}})
            assign(socket, changeset: changeset)
        end
      end

      defoverridable [update: 2]
    end
  end
end
