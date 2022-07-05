defmodule EctoLiveWeb.Base do
  defmacro __using__(_) do
    quote do
      use Phoenix.LiveComponent
      alias EctoLive.Helpers

      @impl true
      def update(%{schema: schema} = assigns, socket) do
        socket = assign(socket,
          schema: schema,
          attributes: Helpers.attributes_without_fkeys(schema),
          actions: Map.get(assigns, :actions, []),
          action: Map.get(assigns, :action, []),
          links: Map.get(assigns, :links, [])
        )

        {:ok, socket}
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
