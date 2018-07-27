defmodule PhxGraphql.Users.User do
  require Logger

  @record [:id, :username, :created, :company, :version]

  defstruct @record

  def new(%{"doc" => map}) do
    new(map)
  end

  def new(map) do
    m2 =
      map
      |> Map.put("id", map["_id"])
      |> Map.put("version", map["_rev"])

    rec = Enum.reduce(@record, %{}, fn x, y -> Map.put(y, x, m2[Atom.to_string(x)]) end)
    struct(%__MODULE__{}, rec)
  end

  def to_doc(map) do
    map
    |> Map.put("_id", map["id"])
    |> Map.put("_rev", map["version"])
    |> Map.delete("id")
    |> Map.delete("version")
  end
end
