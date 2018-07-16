defmodule Views.User do
  def user_by_email do
    %{
      doc: "_design/user",
      db: "phx_graphql",
      view: "by_email",
      map: "function(doc) {\n  if(doc.type == \"user\"){\n    emit(doc.email, null);\n  }\n}"
    }
  end
end
