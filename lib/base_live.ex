defmodule EctoLiveWeb.BaseLive do
  defmacro __using__(_) do
    quote do
      import Inflex
      alias EctoLive.Helpers
      use Phoenix.LiveView

      @impl true
      def mount(params, session, socket) do
        case connected?(socket) do
          true  ->
            socket = handle_connect(params, session, socket)
            {:ok, assign(socket, loading: false)}
          false ->
            {:ok, assign(socket, loading: true)}
        end
      end

      def handle_connect(%{"resource_name" => resource_name} = params, _session, socket) do
        schema = resource_module(resource_name)

        resource = case params do
          %{"id" => id} ->
            Helpers.repo().get(schema, id)
          _ ->
            struct(schema, params |> Map.new(fn {key, value} -> {String.to_atom(key), value} end))
        end

        socket = assign(
          socket,
          redirect_to: params["redirect_to"],
          resource: resource,
          resource_name: resource_name,
          schema: schema
        )

        socket = case socket.assigns.live_action do
          :index -> assign(socket, resources: Helpers.repo().all(schema))
          _ -> socket
        end

        # If building a new resource, use the params as prefilling
        params = case socket.assigns.live_action do
          :new -> params
          _ -> %{}
        end

        assign(socket, changeset: schema.changeset(socket.assigns.resource, params))
      end

      @impl true
      def handle_info({:error, {:action, _, msg}}, socket) do
        socket = socket |> put_flash(:error, msg)
        {:noreply, socket}
      end

      @impl true
      def handle_info({:ok, {:action, name, _}}, socket) do
        socket =
          socket
          |> put_flash(:info, "Resource successfully #{name}-ed!")
          |> push_redirect(to: Routes.crud_path(socket, :index, socket.assigns.resource_name))

        {:noreply, socket}
      end

      def module_map do
        %{
          "projects" => Narraflow.Admin.Project,
          "scenes" => Narraflow.Admin.Scene,
          "nodes" => Narraflow.Admin.Node,
          "links" => Narraflow.Admin.Link,
          "sourced_links" => Narraflow.Admin.Link,
          "targeted_links" => Narraflow.Admin.Link,
          "save_files" => Narraflow.Admin.SaveFile
        }
      end

      def resource_module(resource_name) do
        module_map()[resource_name]
      end
    end
  end
end
