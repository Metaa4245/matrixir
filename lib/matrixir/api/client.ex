defmodule Matrixir.API.Client do
  @moduledoc false

  @type finch :: {:ok, Finch.Response.t()} | {:error, Exception.t()}
  @type response :: Matrixir.API.response()
  @type method :: Finch.Request.method()
  @type body :: Finch.Response.body()
  @type url :: Finch.Response.url()
  @type api :: Matrixir.API.t()

  @spec request(api(), method(), url(), body() | nil) :: finch()
  def request(api, method, route, body \\ nil) do
    headers =
      case api.access_token do
        nil -> []
        x -> [{"Authorization", "Bearer #{x}"}]
      end

    Finch.build(method, "#{api.base_url}#{route}", headers, body)
    |> Finch.request(MatrixirAPIFinch)
    |> handle_response()
  end

  @spec get(api(), url()) :: finch()
  def get(api, route) do
    request(api, :get, route)
  end

  @spec post(api(), url(), body()) :: finch()
  def post(api, route, body) do
    request(api, :post, route, body)
  end

  @spec put(api(), url(), body()) :: finch()
  def put(api, route, body) do
    request(api, :put, route, body)
  end

  @spec delete(api(), url(), body() | nil) :: finch()
  def delete(api, route, body \\ nil) do
    request(api, :delete, route, body)
  end

  def handle_response({:ok, %Finch.Response{status: 200, body: body}}) do
    case JSON.decode(body) do
      {:ok, json} -> {:ok, json}
      {:error, error} -> {:error, Matrixir.Error.__new__(:decode, error)}
    end
  end

  def handle_response({:ok, %Finch.Response{status: _, body: body}}) do
    case JSON.decode(body) do
      {:ok, json} -> {:error, Matrixir.Error.__new__(:matrix, Matrixir.API.Error.from_json(json))}
      {:error, error} -> {:error, Matrixir.Error.__new__(:decode, error)}
    end
  end

  def handle_response({:error, reason}) do
    {:error, Matrixir.Error.__new__(:other, reason)}
  end
end
