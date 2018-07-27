defmodule PhxGraphql.Things.Thing do
  require Logger

  @record [:id, :description, :user]

  defstruct @record

  def new(%{"doc" => map}) do
    new(map)
  end

  def new(map) do
    m2 = Map.put(map, "id", map["_id"])
    rec = Enum.reduce(@record, %{}, fn x, y -> Map.put(y, x, m2[Atom.to_string(x)]) end)
    struct(%__MODULE__{}, rec)
  end
end
