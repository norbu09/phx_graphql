defmodule Views.Things do
  def things_all do
    %{
      doc: "_design/things",
      db: "phx_graphql",
      view: "all",
      map: "function(doc) {\n  if(doc.type == \"thing\"){\n    emit(doc._id, null);\n  }\n}"
    }
  end
end
