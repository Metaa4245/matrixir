defmodule Matrixir.API do
  @moduledoc """
  Wrappers for the Matrix API.
  """

  defstruct [
    :base_url,
    :access_token
  ]

  @type t :: %__MODULE__{
          base_url: String.t(),
          access_token: String.t()
        }

  @type finch :: {:ok, Finch.Response.t()} | {:error, Exception.t()}
  @type body :: Finch.Response.body()
  @type url :: Finch.Response.url()

  @type api :: {:ok, map()} | {:error, Matrixir.Error.t()}

  @profile_endpoint "/_matrix/client/v3/profile"
  @user_endpoint "/_matrix/client/v3/user"

  @spec new(String.t(), String.t()) :: t()
  def new(base_url, access_token) do
    Finch.start_link(name: MatrixirAPIFinch)

    %__MODULE__{
      base_url: base_url,
      access_token: access_token
    }
  end

  @spec request(
          t(),
          Finch.Request.method(),
          Finch.Request.url(),
          Finch.Request.body()
        ) :: finch()
  defp request(api, method, route, body \\ nil) do
    Finch.build(
      method,
      "#{api.base_url}#{route}",
      [
        {"Authorization", "Bearer #{api.access_token}"}
      ],
      body
    )
    |> Finch.request(MatrixirAPIFinch)
  end

  @spec get(t(), url()) :: finch()
  defp get(api, route) do
    request(api, :get, route)
  end

  @spec put(t(), url(), body()) :: finch()
  defp put(api, route, body) do
    request(api, :put, route, body)
  end

  @spec delete(t(), url(), body() | nil) :: finch()
  defp delete(api, route, body \\ nil) do
    request(api, :delete, route, body)
  end

  defp handle_response({:ok, %Finch.Response{status: 200, body: body}}) do
    with {:ok, json} <- JSON.decode(body) do
      {:ok, json}
    else
      {:error, error} -> {:error, Matrixir.Error.new(:decode, error)}
    end
  end

  defp handle_response({:ok, %Finch.Response{status: 400, body: body}}) do
    with {:ok, json} <- JSON.decode(body) do
      {:error, Matrixir.Error.new(:matrix, json)}
    else
      {:error, error} -> {:error, Matrixir.Error.new(:decode, error)}
    end
  end

  defp handle_response({:ok, %Finch.Response{status: 403, body: body}}) do
    with {:ok, json} <- JSON.decode(body) do
      {:error, Matrixir.Error.new(:matrix, json)}
    else
      {:error, error} -> {:error, Matrixir.Error.new(:decode, error)}
    end
  end

  defp handle_response({:ok, %Finch.Response{status: 405, body: body}}) do
    with {:ok, json} <- JSON.decode(body) do
      {:error, Matrixir.Error.new(:matrix, json)}
    else
      {:error, error} -> {:error, Matrixir.Error.new(:decode, error)}
    end
  end

  defp handle_response({:ok, %Finch.Response{status: status}}) do
    {:error, Matrixir.Error.new(:http, status)}
  end

  defp handle_response({:error, reason}) do
    {:error, Matrixir.Error.new(:other, reason)}
  end

  @spec get_user_info(t(), String.t()) :: api()
  def get_user_info(api, user) do
    get(api, "#{@profile_endpoint}/#{user}") |> handle_response()
  end

  @spec get_user_avatar(t(), String.t()) :: api()
  def get_user_avatar(api, user) do
    get(api, "#{@profile_endpoint}/#{user}/avatar_url") |> handle_response()
  end

  @spec get_user_display_name(t(), String.t()) :: api()
  def get_user_display_name(api, user) do
    get(api, "#{@profile_endpoint}/#{user}/displayname") |> handle_response()
  end

  @spec get_user_data(t(), String.t(), String.t()) :: api()
  def get_user_data(api, user, type) do
    get(api, "#{@user_endpoint}/#{user}/account_data/#{type}") |> handle_response()
  end

  @spec get_room_user_data(t(), String.t(), String.t(), String.t()) :: api()
  def get_room_user_data(api, user, room_id, type) do
    get(
      api,
      "#{@user_endpoint}/#{user}/rooms/#{room_id}/account_data/#{type}"
    )
    |> handle_response()
  end

  @spec set_user_avatar(t(), String.t(), String.t()) :: api()
  def set_user_avatar(api, user, avatar) do
    put(
      api,
      "#{@profile_endpoint}/#{user}/avatar_url",
      JSON.encode!(%{avatar_url: avatar})
    )
    |> handle_response()
  end

  @spec set_user_display_name(t(), String.t(), String.t()) :: api()
  def set_user_display_name(api, user, display_name) do
    put(
      api,
      "#{@profile_endpoint}/#{user}/displayname",
      JSON.encode!(%{displayname: display_name})
    )
    |> handle_response()
  end

  @spec set_user_data(t(), String.t(), String.t(), map()) :: api()
  def set_user_data(api, user, type, data) do
    put(
      api,
      "#{@user_endpoint}/#{user}/account_data/#{type}",
      JSON.encode!(data)
    )
    |> handle_response()
  end

  @spec set_room_user_data(
          t(),
          String.t(),
          String.t(),
          String.t(),
          map()
        ) :: api()
  def set_room_user_data(api, user, room, type, data) do
    put(
      api,
      "#{@user_endpoint}/#{user}/rooms/#{room}/account_data/#{type}",
      JSON.encode!(data)
    )
    |> handle_response()
  end

  @spec get_room_user_tags(t(), String.t(), String.t()) :: api()
  def get_room_user_tags(api, user, room) do
    get(api, "#{@user_endpoint}/#{user}/rooms/#{room}/tags")
    |> handle_response()
  end

  # TODO: data, is it only order and thus i can get away with order?
  # or can tags have custom data? idk matrix "tags"
  @spec add_room_user_tag(
          t(),
          String.t(),
          String.t(),
          String.t(),
          map()
        ) :: api()
  def add_room_user_tag(api, user, room, tag, data) do
    put(
      api,
      "#{@user_endpoint}/#{user}/rooms/#{room}/tags/#{tag}",
      JSON.encode!(data)
    )
    |> handle_response()
  end

  @spec remove_room_user_tag(t(), String.t(), String.t(), String.t()) :: api()
  def remove_room_user_tag(api, user, room, tag) do
    delete(
      api,
      "#{@user_endpoint}/#{user}/rooms/#{room}/tags/#{tag}"
    )
    |> handle_response()
  end
end
