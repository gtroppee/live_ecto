defmodule EctoLive.Helpers do
  def repo do
    Application.get_env(:live_ecto, :repo)
  end

  def all(queryable, opts \\ []) do
    repo().all(queryable, opts)
  end

  # def search(queryable, %{"term" => term}) do
  #   from(u in queryable, where: like(u.name, ^"%#{term}%")) |> repo().all
  # end

  def get(queryable, id, opts \\ []) do
    repo().get(queryable, id, opts)
  end

  def new(queryable) do
    queryable.__struct__
  end

  def get_or_new(queryable, nil) do
    new(queryable)
  end

  def get_or_new(queryable, id) do
    get(queryable, id)
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

  def validate(queryable, params) do
    queryable.__struct__
    |> queryable.changeset(params)
    |> Map.put(:action, :insert_or_update)
  end

  def save(resource, params, opts \\ []) do
    resource
    |> resource.__struct__.changeset(params)
    |> repo().insert_or_update(opts)
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

  def attributes(module) do
    module |> fields |> Enum.reject(fn {name, _} -> name == :id end)
  end
end
