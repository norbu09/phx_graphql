defmodule Views.User do
  def user_by_username do
    %{
      doc: "_design/user",
      db: "phx_graphql",
      view: "by_username",
      map: "function(doc) {\n  if(doc.type == \"user\"){\n    emit(doc.username, null);\n  }\n}"
    }
  end
end
