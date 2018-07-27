defmodule Views.Things do

  def things_all do
    %{
      doc: "_design/things",
      view: "all",
      map: "function(doc) {\n  if(doc.type == \"thing\"){\n    emit(doc._id, null);\n  }\n}"
    }
  end

  def things_by_user do
    %{
      doc: "_design/things",
      view: "by_user",
      map: "function(doc) {\n  if(doc.type == \"thing\"){\n    emit(doc.user, null);\n  }\n}"
    }
  end
end
