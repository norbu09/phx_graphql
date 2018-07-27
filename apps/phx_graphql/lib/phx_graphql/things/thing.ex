defmodule PhxGraphql.Things.Thing do
  require Logger

  @record [:id, :version, :description, :user]

  defstruct @record

  def new(%{"doc" => map}) do
    new(map)
  end

  def new(map) do
    m2 = map
         |> Map.put("id", map["_id"])
         |> Map.put("version", map["_rev"])
    rec = Enum.reduce(@record, %{}, fn x, y -> Map.put(y, x, m2[Atom.to_string(x)]) end)
    struct(%__MODULE__{}, rec)
  end
end
