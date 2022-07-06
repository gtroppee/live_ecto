defmodule EctoLive.Helpers do
  def repo do
    Application.get_env(:live_ecto, :repo)
  end

  def routes do
    Application.get_env(:live_ecto, :routes)
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
    |> Enum.reject(fn field -> Enum.member?([:inserted_at, :updated_at], field) end)
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
end
