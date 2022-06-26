defmodule EctoLiveWeb.Helpers.Json do
  use Phoenix.LiveComponent

  def update(%{value: value}, socket) do
    {:ok, assign(
      socket,
      value: get_json_object_from_value(value)
    )}
  end

  defp get_json_object_from_value(value) when is_binary(value) do
    case Jason.decode(value) do
      {:ok, decoded_value} -> decoded_value
      {:error, _} -> value
    end
  end

  defp get_json_object_from_value(value) do
    value
  end
end
