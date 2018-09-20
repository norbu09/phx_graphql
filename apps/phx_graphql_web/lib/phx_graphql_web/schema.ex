defmodule PhxGraphqlWeb.Schema do
  use Absinthe.Schema
  require Logger
  alias PhxGraphqlWeb.ThingResolver
  alias PhxGraphqlWeb.ProfileResolver

  object :thing do
    field(:id, non_null(:id))
    field(:description, non_null(:string))
    field(:version, :string)
  end

  object :profile do
    field(:id, non_null(:id))
    field(:version, non_null(:string))
    field(:username, non_null(:string))
    field(:company, :string)
  end

  object :token do
    field(:token, non_null(:id))
    field(:created, non_null(:integer))
  end

  input_object :profile_input do
    field(:id, non_null(:id))
    field(:version, non_null(:string))
    field(:username, :string)
    field(:company, :string)
  end

  object :activity do
    field(:user_id, :id)
    field(:message, :string)
  end

  query do
    @desc "Get a user profile"
    field :get_profile, non_null(:profile) do
      arg(:id, :id)
      resolve(&ProfileResolver.get_profile/3)
    end

    @desc "Get all user token"
    field :all_token, list_of(:token) do
      resolve(&ProfileResolver.get_token/3)
    end

    @desc "Get all things"
    field :all_things, non_null(list_of(non_null(:thing))) do
      resolve(&ThingResolver.all_things/3)
    end

    @desc "Get a specific thing"
    field :thing, :thing do
      arg(:id, non_null(:id))
      resolve(&ThingResolver.find_thing/3)
    end

    @desc "Get all user things"
    field :all_user_things, non_null(list_of(non_null(:thing))) do
      resolve(&ThingResolver.user_things/3)
    end

    @desc "Get a user log entry"
    field :user_activity, list_of(:activity) do
      arg(:user_id, :id)
      resolve(&first_log/3)
    end
  end

  mutation do
    @desc "Update a user profile"
    field :update_profile, non_null(:profile) do
      arg(:profile, non_null(:profile_input))
      resolve(&ProfileResolver.upd_profile/3)
    end

    @desc "Update a user password"
    field :update_password, non_null(:profile) do
      arg(:current_password, non_null(:string))
      arg(:new_password, non_null(:string))
      resolve(&ProfileResolver.upd_passwd/3)
    end

    @desc "Create an API token for a user"
    field :create_token, list_of(:token) do
      resolve(&ProfileResolver.add_token/3)
    end

    @desc "Delete an API token for a user"
    field :delete_token, list_of(:token) do
      arg(:token, non_null(:string))
      resolve(&ProfileResolver.del_token/3)
    end

    @desc "Create a things"
    field :create_thing, :thing do
      arg(:description, non_null(:string))

      resolve(&ThingResolver.create_thing/3)
    end

    @desc "Delete a things"
    field :delete_thing, :thing do
      arg(:id, non_null(:id))
      arg(:version, non_null(:string))

      resolve(&ThingResolver.delete_thing/3)
    end

    @desc "Create a user log entry"
    field :log_activity, :activity do
      arg(:user_id, :id)
      arg(:message, :string)
      resolve(&log_acc/3)
    end
  end

  subscription do
    field :user_activity, :activity do
      arg(:user_id, non_null(:id))

      config(fn args, _ ->
        Logger.debug("[subscription] args: #{inspect(args)}")
        {:ok, topic: args.user_id}
      end)

      trigger(
        :log_activity,
        topic: fn log ->
          log.user_id
        end
      )

      resolve(fn log, _, _ ->
        Logger.debug("[subscription] log: #{inspect(log)}")
        {:ok, log}
      end)
    end
  end

  defp first_log(_root, params, _) do
    {:ok, [%{message: "foo", user_id: params[:user_id]}]}
  end

  defp log_acc(_root, params, _) do
    Logger.debug("[activity log] #{inspect(params)}")
    {:ok, %{message: params[:message], user_id: params[:user_id]}}
  end
end
