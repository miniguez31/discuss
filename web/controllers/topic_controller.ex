defmodule Discuss.TopicController do
  use Discuss.Web, :controller

  alias Discuss.Topic


  plug Discuss.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
  plug :check_topic_owner when action in [:update, :edit, :delete]
  
  def new(conn, _params) do
   # IO.puts "++++"
   # IO.inspect conn
   # IO.puts "++++"
   # IO.inspect params
    # IOe.puts "++++"
#    struct = %Topic{}
#    params = %{}
    changeset = Topic.changeset( %Topic{}, %{})

    render conn, "new.html", changeset: changeset
  end


  def create(conn, %{"topic" => topic}) do
  #def create(conn, params) do
    #    IO.inspect(params)
    #%{"topic" => topic } = params

    #Comment when it can uses a user logged
    #changeset = Topic.changeset(%Topic{}, topic)

    #create assoc with the user
    changeset = conn.assigns.user
    |> build_assoc(:topics)
    |> Topic.changeset(topic)
    
    case Repo.insert(changeset) do
      # {:ok, post} -> IO.inspect(post)
      # {:error, changeset} -> IO.inspect(changeset)
      {:ok, _topic} ->
	conn
	|> put_flash(:info, "Topic created!")
	|> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
	render conn, "new.html", changeset: changeset
    end
  end

  def index(conn, _params) do
    IO.inspect(conn.assigns)
    
    topics = Repo.all(Topic)
    render conn, "index.html", topics: topics
  end

  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(topic)

    render conn, "edit.html", changeset: changeset, topic: topic
  end

  def update(conn, %{"id" => topic_id, "topic" => topic}) do
    old_topic = Repo.get(Topic, topic_id)   
    changeset = Topic.changeset(old_topic, topic)

     case Repo.update(changeset) do
      {:ok, _topic} ->
	conn
	|> put_flash(:info, "Topic updated!")
	|> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
	render conn, "edit.html", changeset: changeset, topic: old_topic
     end
  end
  
  def delete(conn, %{"id" => topic_id}) do
    Repo.get!(Topic, topic_id) |> Repo.delete!
	      
    conn
    |> put_flash(:info, "Topic deleted")
    |> redirect(to: topic_path(conn, :index))
  end

  def check_topic_owner(conn, _params) do
    %{params: %{"id" => topic_id}} = conn
    if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "You cannot edit that")
      |> redirect(to: topic_path(conn, :index))
      |> halt()
    end
  end
end
