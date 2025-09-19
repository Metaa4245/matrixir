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

  defdelegate discovery_info(api), to: Matrixir.API.ServerAdmin
  defdelegate support_info(api), to: Matrixir.API.ServerAdmin
  defdelegate whois(api, user), to: Matrixir.API.ServerAdmin
  defdelegate spec_versions(api), to: Matrixir.API.ServerAdmin
  defdelegate ping_appservice(api, id, transaction_id \\ nil), to: Matrixir.API.ServerAdmin
  defdelegate room_summary(api, room, via \\ []), to: Matrixir.API.ServerAdmin
  defdelegate refresh_access_token(api, refresh_token), to: Matrixir.API.ServerAdmin
  defdelegate presence(api, user), to: Matrixir.API.Presence

  defdelegate put_presence(api, user, presence, status_message \\ nil),
    to: Matrixir.API.Presence

  defdelegate info(api, user), to: Matrixir.API.UserData
  defdelegate avatar_url(api, user), to: Matrixir.API.UserData
  defdelegate display_name(api, user), to: Matrixir.API.UserData
  defdelegate account_data(api, user, type), to: Matrixir.API.UserData
  defdelegate room_account_data(api, user, room, type), to: Matrixir.API.UserData
  defdelegate put_avatar_url(api, user, avatar), to: Matrixir.API.UserData
  defdelegate put_display_name(api, user, display_name), to: Matrixir.API.UserData
  defdelegate put_account_data(api, user, type, data), to: Matrixir.API.UserData
  defdelegate put_room_account_data(api, user, room, type, data), to: Matrixir.API.UserData
  defdelegate room_user_tags(api, user, room), to: Matrixir.API.UserData
  defdelegate put_room_user_tag(api, user, room, tag, data), to: Matrixir.API.UserData
  defdelegate delete_room_user_tag(api, user, room, tag), to: Matrixir.API.UserData
  defdelegate upgrade(api, room, version), to: Matrixir.API.RoomUpgrade
end
