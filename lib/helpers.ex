defmodule EctoLive.Helpers do
  def repo do
    Application.get_env(:live_ecto, :repo)
  end

  def routes do
    Application.get_env(:live_ecto, :routes)
  end

  def schemas do
    Application.get_env(:live_ecto, :schemas)
  end

  def actions do
    Application.get_env(:live_ecto, :actions)
  end

  def links do
    Application.get_env(:live_ecto, :links)
  end

  def declare_fkey_constraints(schema, changeset) do
    child_associations(schema)
    |> Enum.map(fn a -> a.field end)
    |> Enum.reduce(changeset, fn name, acc ->
      acc
      |> Ecto.Changeset.change
      |> Ecto.Changeset.no_assoc_constraint(name, message: "are still associated with this entry. Please delete them in order to proceed.")
    end)
  end

  def resource_id(resource) do
    [key] = resource.__struct__.__schema__(:primary_key)
    Map.get(resource, key)
  end

  def parent_associations(module) do
    module
    |> associations
    |> Enum.filter(fn ass -> is_struct(ass, Ecto.Association.BelongsTo) end)
  end

  def child_associations(module) do
    module
    |> associations
    |> Enum.filter(fn ass -> is_struct(ass, Ecto.Association.Has) end)
  end

  def associations(module) do
    module.__schema__(:associations)
    |> Enum.map(fn field -> module.__schema__(:association, field) end)
  end

  def fields(module) do
    module.__schema__(:fields)
    # |> Enum.reject(fn field -> Enum.member?([:inserted_at, :updated_at], field) end)
    |> Enum.map(fn field ->
      {field, module.__schema__(:type, field)}
    end)
  end

  def attributes_without_fkeys(module) do
    module |> attributes |> Enum.reject(fn {_, type} -> type == :id end)
  end

  def attributes(module) do
    module |> fields |> Enum.reject(fn {name, _} -> name == :id end)
  end

  @doc """
  Convert map string keys to :atom keys
  source: https://gist.github.com/kipcole9/0bd4c6fb6109bfec9955f785087f53fb
  """
  def atomize_keys(nil), do: nil

  # Structs don't do enumerable and anyway the keys are already
  # atoms
  def atomize_keys(struct = %{__struct__: _}) do
    struct
  end

  def atomize_keys(map = %{}) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), atomize_keys(v)} end)
    |> Enum.into(%{})
  end

  # Walk the list and atomize the keys of
  # of any map members
  def atomize_keys([head | rest]) do
    [atomize_keys(head) | atomize_keys(rest)]
  end

  def atomize_keys(not_a_map) do
    not_a_map
  end
end
