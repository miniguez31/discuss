defmodule Discuss.CommentsChannel do
  use Discuss.Web, :channel

  alias Discuss.{Topic, Comment}
  
  #def join(name, _params, socket) do
  def join("comments:" <> topic_id , _params, socket) do
    #IO.puts("+++++++++++++++++")
    #IO.puts(name)
    topic_id = String.to_integer(topic_id)
    #topic = Repo.get(Topic, topic_id)
    topic = Topic
    |> Repo.get(topic_id)
    #|> Repo.preload(:comments)
    |> Repo.preload(comments: [:user])
    

    #IO.puts("+++++++++++++++++")
    #IO.puts("+++++++++++++++++")
    #IO.inspect(topic)

    
    # {:ok, %{hey: "there"}, socket}
    # {:ok, %{}, socket}

    # {:ok, %{}, assign(socket, :topic, topic)}
    {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
  end

  #def handle_in(name, message, socket) do
  def handle_in(name, %{"content" => content}, socket) do
    #IO.puts("+++++++++++++++++")
    #IO.puts(name)
    #IO.inspect(message)
    topic = socket.assigns.topic
    user_id = socket.assigns.user_id

    changeset = topic
#|> build_assoc(:comments)
    |> build_assoc(:comments, user_id: user_id)
    |> Comment.changeset(%{content: content})

    case Repo.insert(changeset) do
      {:ok, comment} ->
	broadcast!(socket, "comments:#{socket.assigns.topic.id}:new", %{comment: comment})
	{:reply, :ok, socket}	
      {:error, _reason} ->
	{:reply, {:error, %{errors: changeset}}, socket}
    end
    
    # {:reply, :ok, socket}
  end
end
