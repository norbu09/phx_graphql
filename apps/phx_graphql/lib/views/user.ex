defmodule Views.User do
  def user_by_username do
    %{
      doc: "_design/user",
      view: "by_username",
      map: "function(doc) {if(doc.type == \"user\"){emit(doc.username, null);}}"
    }
  end

  def user_by_token do
    %{
      doc: "_design/user",
      view: "by_token",
      map: "function(doc) {if(doc.type == \"user\"){for(i in doc.token){emit(doc.token[i], null);}}}"
    }
  end
end
