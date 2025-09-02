defmodule Matrixir.API do
  @moduledoc """
  Wrappers for the Matrix API.

  This module delegates functions to category specific API modules.
  """

  defstruct [
    :base_url,
    :access_token
  ]

  @typedoc """
  API wrapper.

  `base_url` represents the matrix homeserver.

  `access_token` represents the client's access token.
  """
  @type t :: %__MODULE__{
          base_url: String.t(),
          access_token: String.t()
        }

  @typedoc """
  Represents a response from the Matrix API. This could either be OK with a map
  or an error `t:Matrixir.Error.t/0`.
  """
  @type response :: {:ok, map()} | {:error, Matrixir.Error.t()}

  @doc """
  Creates a new `Matrixir` API struct.
  Pass the Matrix homeserver and access_token.

  Pass the struct to the wrapper functions.

  Note: this creates a Finch client under the name `MatrixirAPIFinch` for now.
  """
  @spec new(String.t(), String.t()) :: t()
  def new(base_url, access_token) do
    Finch.start_link(name: MatrixirAPIFinch)

    %__MODULE__{
      base_url: base_url,
      access_token: access_token
    }
  end

  defdelegate get_user_info(api, user), to: Matrixir.API.UserData
  defdelegate get_user_avatar(api, user), to: Matrixir.API.UserData
  defdelegate get_user_display_name(api, user), to: Matrixir.API.UserData
  defdelegate get_user_data(api, user, type), to: Matrixir.API.UserData
  defdelegate get_room_user_data(api, user, room, type), to: Matrixir.API.UserData
  defdelegate set_user_avatar(api, user, avatar), to: Matrixir.API.UserData
  defdelegate set_user_display_name(api, user, display_name), to: Matrixir.API.UserData
  defdelegate set_user_data(api, user, type, data), to: Matrixir.API.UserData
  defdelegate set_room_user_data(api, user, room, type, data), to: Matrixir.API.UserData
  defdelegate get_room_user_tags(api, user, room), to: Matrixir.API.UserData
  defdelegate add_room_user_tag(api, user, room, tag, data), to: Matrixir.API.UserData
  defdelegate remove_room_user_tag(api, user, room, tag), to: Matrixir.API.UserData
end
