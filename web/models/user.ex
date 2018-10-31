defmodule Discuss.User do
  use Discuss.Web, :model


  schema "users" do
    field :email, :string
    field :provider, :string
    field :token, :string
    has_many :topics, Discuss.Topic
    
    timestamps()
  end

  def changeset(strunct, params \\ %{}) do
    strunct
    |> cast(params, [:email, :provider, :token])
    |> validate_required([:email, :provider, :token])
  end

  
end
