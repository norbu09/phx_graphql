defmodule PhxGraphqlWeb.Schema do
  use Absinthe.Schema
  alias PhxGraphqlWeb.ThingResolver

  object :thing do
    field(:id, non_null(:id))
    field(:description, non_null(:string))
  end

  query do
    @desc "Get all things"
    field :all_things, non_null(list_of(non_null(:thing))) do
      resolve(&ThingResolver.all_things/3)
    end

    @desc "Get a specific thing"
    field :thing, :thing do
      arg(:id, non_null(:id))
      resolve(&ThingResolver.find_thing/3)
    end
  end

  mutation do
    @desc "Create a things"
    field :create_thing, :thing do
      arg(:description, non_null(:string))

      resolve(&ThingResolver.create_thing/3)
    end
  end
  
end
