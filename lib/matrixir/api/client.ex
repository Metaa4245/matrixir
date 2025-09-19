defmodule Matrixir.API.Client do
  @moduledoc false

  @type finch :: {:ok, Finch.Response.t()} | {:error, Exception.t()}
  @type response :: Matrixir.API.response()
  @type method :: Finch.Request.method()
  @type body :: Finch.Request.body()
  @type url :: Finch.Request.url()
  @type api :: Matrixir.API.t()

  @spec request(api(), method(), url(), body() | nil, boolean()) :: finch()
  def request(
        api,
        method,
        route,
        body \\ nil,
        json? \\ true,
        where \\ nil
      ) do
    where = where || api.base_url

    {url, where} =
      case URI.parse(route) do
        %URI{scheme: nil} ->
          {where <> route, where}

        %URI{scheme: scheme} = uri when scheme in ["http", "https"] ->
          {route, "#{uri.scheme}://#{uri.host}"}
      end

    headers =
      case api.access_token do
        nil -> []
        x -> [{"Authorization", "Bearer #{x}"}]
      end

    response =
      method
      |> Finch.build(url, headers, body)
      |> Finch.request(MatrixirAPIFinch)

    case response do
      {:ok, %Finch.Response{status: status, headers: headers}}
      when status in [307, 308] ->
        {"location", new_url} = List.keyfind!(headers, "location", 0)

        request(api, method, new_url, body, json?, where)

      _ ->
        handle_response(response, json?)
    end
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

  def handle_response({:ok, %Finch.Response{status: 200, body: body}}, json?) do
    if json? do
      case JSON.decode(body) do
        {:ok, json} -> {:ok, json}
        {:error, error} -> {:error, Matrixir.Error.__new__(:decode, error)}
      end
    else
      {:ok, body}
    end
  end

  def handle_response({:ok, %Finch.Response{status: _, body: body}}, _json?) do
    case JSON.decode(body) do
      {:ok, json} -> {:error, Matrixir.Error.__new__(:matrix, Matrixir.API.Error.from_json(json))}
      {:error, error} -> {:error, Matrixir.Error.__new__(:decode, error)}
    end
  end

  def handle_response({:error, reason}, _json?) do
    {:error, Matrixir.Error.__new__(:other, reason)}
  end
end
