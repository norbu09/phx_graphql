defmodule PhxGraphqlWeb.Guardian.AuthErrorHandler do

  use PhxGraphqlWeb, :controller
  require Logger

  # needs the following implemented:
  # The failure types that come out of the box are:

  #  :invalid_token
  #  :unauthorized
  #  :unauthenticated
  #  :already_authenticated
  #  :no_resource_found

  
  def auth_error(conn, {:unauthenticated, reason}, opts) do
    Logger.error("Unauthenticated: #{inspect reason} with opts: #{inspect opts}")
    redirect(conn, to: "/")
  end
  def auth_error(conn, {type, reason}, _opts) do
    Logger.error("Got an unhandeled auth error: #{inspect type}: #{inspect reason}")
    #redirect(conn, to: "/")
    conn
  end
  
end