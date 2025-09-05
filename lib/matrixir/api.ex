defmodule Matrixir.API do
  @moduledoc """
  Wrappers for the Matrix API.

  This module delegates functions to category specific API modules.
  """

  @enforce_keys [:base_url]
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
          access_token: String.t() | nil
        }

  @typedoc """
  Represents a response from the Matrix API. This could either be OK with a map
  or an error `t:Matrixir.Error.t/0`.
  """
  @type response :: {:ok, map()} | {:error, Matrixir.Error.t()}

  @doc """
  Creates a new `Matrixir` API struct.
  Pass the Matrix homeserver. `access_token` is by default `nil`.

  Pass the struct to the wrapper functions.

  Note: this creates a Finch client under the name `MatrixirAPIFinch` for now.
  """
  @spec new(String.t(), String.t() | nil) :: t()
  def new(base_url, access_token \\ nil) do
    Finch.start_link(name: MatrixirAPIFinch)

    %__MODULE__{
      base_url: base_url,
      access_token: access_token
    }
  end

  defdelegate get_discovery_info(api), to: Matrixir.API.ServerAdmin
  defdelegate get_support_info(api), to: Matrixir.API.ServerAdmin
  defdelegate whois(api, user), to: Matrixir.API.ServerAdmin
  defdelegate get_spec_versions(api), to: Matrixir.API.ServerAdmin
  defdelegate ping_app_service(api, id, transaction_id \\ nil), to: Matrixir.API.ServerAdmin
  defdelegate get_room_summary(api, room, via \\ []), to: Matrixir.API.ServerAdmin
  defdelegate refresh_access_token(api, refresh_token), to: Matrixir.API.ServerAdmin
  defdelegate get_user_presence(api, user), to: Matrixir.API.Presence
  defdelegate set_user_presence(api, user, presence, status_message \\ nil), to: Matrixir.API.Presence
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
