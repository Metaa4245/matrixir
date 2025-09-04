defmodule Matrixir.API.UserData do
  @moduledoc """
  Matrix user data endpoints.
  """

  @typedoc """
  Alias for `t:Matrixir.API.response/0`.
  """
  @type response :: Matrixir.API.response()

  @typedoc """
  Alias for `t:Matrixir.API.t/0`.
  """
  @type api :: Matrixir.API.t()

  @profile_endpoint "/_matrix/client/v3/profile"
  @user_endpoint "/_matrix/client/v3/user"

  alias Matrixir.API.Client
  import Matrixir.DocHelpers

  api_doc("
  Fetches a user's profile information, including avatar URL and display name.

  This may be used to query the profile of the current user or another user,
  either locally or on a remote homeserver.
  ",
    parameters: [
      {"user", "Matrix user ID (e.g. `@example:homeserver.com`)"}
    ],
    ok: """
    %{
      "avatar_url" => "mxc://homeserver.com/id",
      "displayname" => "Example"
    }
    """,
    errors: [
      {"The server is unwilling to disclose whether the user exists and/or has profile information.",
       """
         error_type: :forbidden,
         error_string: "Profile lookup is disabled on this homeserver"
       """},
      {"There is no profile information for the user or the user does not exist.",
       """
         error_type: :not_found,
         error_string: "Profile not found"
       """}
    ],
    notes: [
      "Not ratelimited",
      "Authentication not required"
    ],
    references: [
      {"Playground", "https://playground.matrix.org/#get-/_matrix/client/v3/profile/-userId-"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#get_matrixclientv3profileuserid"}
    ]
  )

  @spec get_user_info(api(), String.t()) :: response()
  def get_user_info(api, user) do
    Client.get(api, "#{@profile_endpoint}/#{user}")
  end

  api_doc("
  Fetches the user's avatar URL.

  This may be used to query the avatar URL of the current user or another user,
  either locally or on a remote homeserver.
  ",
    parameters: [
      {"user", "Matrix user ID (e.g. `@example:homeserver.com`)"}
    ],
    ok: """
    %{
      "avatar_url" => "mxc://homeserver.com/id"
    }
    """,
    errors: [
      {"The server is unwilling to disclose whether the user exists and/or has an avatar URL.",
       """
         error_type: :forbidden,
         error_string: "Profile lookup is disabled on this homeserver"
       """},
      {"There is no avatar URL for the user or the user does not exist.",
       """
         error_type: :not_found,
         error_string: "Profile not found"
       """}
    ],
    notes: [
      "Not ratelimited",
      "Authentication not required"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#get-/_matrix/client/v3/profile/-userId-/avatar_url"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#get_matrixclientv3profileuseridavatar_url"}
    ]
  )

  @spec get_user_avatar(api(), String.t()) :: response()
  def get_user_avatar(api, user) do
    Client.get(api, "#{@profile_endpoint}/#{user}/avatar_url")
  end

  api_doc("
  Fetches the user's display name.

  This may be used to query the display name of the current user or another user,
  either locally or on a remote homeserver.
  ",
    parameters: [
      {"user", "Matrix user ID (e.g. `@example:homeserver.com`)"}
    ],
    ok: """
    %{
      "displayname" => "Example"
    }
    """,
    errors: [
      {"The server is unwilling to disclose whether the user exists and/or has a display name.",
       """
         error_type: :forbidden,
         error_string: "Profile lookup is disabled on this homeserver"
       """},
      {"There is no display name for the user or the user does not exist.",
       """
         error_type: :not_found,
         error_string: "Profile not found"
       """}
    ],
    notes: [
      "Not ratelimited",
      "Authentication not required"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#get-/_matrix/client/v3/profile/-userId-/displayname"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#get_matrixclientv3profileuseriddisplayname"}
    ]
  )

  @spec get_user_display_name(api(), String.t()) :: response()
  def get_user_display_name(api, user) do
    Client.get(api, "#{@profile_endpoint}/#{user}/displayname")
  end

  api_doc("
  Fetches some account data for the client.

  The config is only visible to the user that set the account data.
  ",
    parameters: [
      {"user", "Matrix user ID (e.g. `@example:homeserver.com`)"},
      {"type", "Event type to fetch"}
    ],
    ok: """
    %{
      "example_account_data_key" => "example_config_value"
    }
    """,
    errors: [
      {"The access token provided is not authorized to retrieve the user's account data.",
       """
         error_type: :forbidden,
         error_string: "Cannot add account data for other users."
       """},
      {"No account data has been provided for the user with the given `type`.",
       """
         error_type: :not_found,
         error_string: "Account data not found."
       """}
    ],
    notes: [
      "Not ratelimited",
      "Authentication required"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#get-/_matrix/client/v3/user/-userId-/account_data/-type-"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#get_matrixclientv3useruseridaccount_datatype"}
    ]
  )

  @spec get_user_data(api(), String.t(), String.t()) :: response()
  def get_user_data(api, user, type) do
    Client.get(api, "#{@user_endpoint}/#{user}/account_data/#{type}")
  end

  api_doc("
  Fetches some account data for the user on a given room.

  The config is only visible to the user that set the account data.
  ",
    parameters: [
      {"user", "Matrix user ID (e.g. `@example:homeserver.com`)"},
      {"room", "Matrix room ID (e.g. `!example:homeserver.com`)"},
      {"type", "Event type to fetch"}
    ],
    ok: """
    %{
      "example_account_data_key" => "example_config_value"
    }
    """,
    errors: [
      {"The `room` provided is not a valid room ID.",
       """
         error_type: :invalid_parameter,
         error_string: "@example:homeserver.com is not a valid room ID."
       """},
      {"The access token provided is not authorized to retrieve the user's account data.",
       """
         error_type: :forbidden,
         error_string: "Cannot add account data for other users."
       """},
      {"No account data has been provided for the user with the given `type`.",
       """
         error_type: :not_found,
         error_string: "Account data not found."
       """}
    ],
    notes: [
      "Not ratelimited",
      "Authentication required"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#get-/_matrix/client/v3/user/-userId-/rooms/-roomId-/account_data/-type-"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#put_matrixclientv3useruseridroomsroomidaccount_datatype"}
    ]
  )

  @spec get_room_user_data(api(), String.t(), String.t(), String.t()) :: response()
  def get_room_user_data(api, user, room, type) do
    Client.get(
      api,
      "#{@user_endpoint}/#{user}/rooms/#{room}/account_data/#{type}"
    )
  end

  api_doc("
  Sets the user's avatar URL.

  You must have permission to set the user's avatar URL, for example having
  their access token.
  ",
    parameters: [
      {"user", "Matrix user ID (e.g. `@example:homeserver.com`)"},
      {"avatar_url", "New avatar URL"}
    ],
    ok: "%{}",
    errors: [
      {"The request was rate-limited.",
       """
         error_type: :limit_exceeded,
         error_string: "Too many requests",
         retry_after: Duration
       """}
    ],
    notes: [
      "Ratelimited",
      "Authentication required"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#put-/_matrix/client/v3/profile/-userId-/avatar_url"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#put_matrixclientv3profileuseridavatar_url"}
    ]
  )

  @spec set_user_avatar(api(), String.t(), String.t()) :: response()
  def set_user_avatar(api, user, avatar) do
    Client.put(
      api,
      "#{@profile_endpoint}/#{user}/avatar_url",
      JSON.encode_to_iodata!(%{avatar_url: avatar})
    )
  end

  api_doc("
  Sets the user's display name.

  You must have permission to set the user's display name, for example having
  their access token.
  ",
    parameters: [
      {"user", "Matrix user ID (e.g. `@example:homeserver.com`)"},
      {"display_name", "New display name"}
    ],
    ok: "%{}",
    errors: [
      {"The request was rate-limited.",
       """
         error_type: :limit_exceeded,
         error_string: "Too many requests",
         retry_after: Duration
       """}
    ],
    notes: [
      "Ratelimited",
      "Authentication required"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#put-/_matrix/client/v3/profile/-userId-/displayname"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#put_matrixclientv3profileuseriddisplayname"}
    ]
  )

  @spec set_user_display_name(api(), String.t(), String.t()) :: response()
  def set_user_display_name(api, user, display_name) do
    Client.put(
      api,
      "#{@profile_endpoint}/#{user}/displayname",
      JSON.encode_to_iodata!(%{displayname: display_name})
    )
  end

  api_doc("
  Sets some account data for the user.

  The config is only visible to the user that set the account data.
  The config will be available through the top-level `account_data` field in
  the homeserver response to `/sync`.
  ",
    parameters: [
      {"user", "Matrix user ID (e.g. `@example:homeserver.com`)"},
      {"type", "Event type to set"},
      {"data", "Elixir map of the data"}
    ],
    ok: "%{}",
    errors: [
      {"The request body is not a JSON object.",
       """
         error_type: :not_json,
         error_string: "Content must be a JSON object."
       """},
      {"The access token provided is not authorized to modify this user’s account data.",
       """
         error_type: :forbidden,
         error_string: "Cannot add account data for other users."
       """},
      {"This `type` of account data is controlled by the server; it cannot be modified by clients.",
       """
         error_type: :not_json,
         error_string: "Cannot set example through this API."
       """}
    ],
    notes: [
      "Not ratelimited",
      "Authentication required"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#put-/_matrix/client/v3/user/-userId-/account_data/-type-"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#put_matrixclientv3useruseridaccount_datatype"}
    ]
  )

  @spec set_user_data(api(), String.t(), String.t(), map()) :: response()
  def set_user_data(api, user, type, data) do
    Client.put(
      api,
      "#{@user_endpoint}/#{user}/account_data/#{type}",
      JSON.encode_to_iodata!(data)
    )
  end

  api_doc("
  Sets some account data for the user on a given room.

  The config is only visible to the user that set the account data.
  The config will be delivered to clients in the per-room entries via `/sync`.
  ",
    parameters: [
      {"user", "Matrix user ID (e.g. `@example:homeserver.com`)"},
      {"room", "Matrix room ID (e.g. `!example:homeserver.com`)"},
      {"type", "Event type to set"},
      {"data", "Elixir map of the data"}
    ],
    ok: "%{}",
    errors: [
      {"The request body is not a JSON object, or the room is not a valid room.",
       """
         error_type: :not_json, # or :invalid_parameter
         error_string: "Content must be a JSON object."
       """},
      {"The access token provided is not authorized to modify this user’s account data.",
       """
         error_type: :forbidden,
         error_string: "Cannot add account data for other users."
       """},
      {"This `type` of account data is controlled by the server; it cannot be modified by clients.",
       """
         error_type: :not_json,
         error_string: "Cannot set example through this API."
       """}
    ],
    notes: [
      "Not ratelimited",
      "Authentication required"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#put-/_matrix/client/v3/user/-userId-/account_data/-type-"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#put_matrixclientv3useruseridaccount_datatype"}
    ]
  )

  @spec set_room_user_data(
          api(),
          String.t(),
          String.t(),
          String.t(),
          map()
        ) :: response()
  def set_room_user_data(api, user, room, type, data) do
    Client.put(
      api,
      "#{@user_endpoint}/#{user}/rooms/#{room}/account_data/#{type}",
      JSON.encode_to_iodata!(data)
    )
  end

  api_doc("
  Fetches the tags set by a user on a room.",
    parameters: [
      {"user", "Matrix user ID (e.g. `@example:homeserver.com`)"},
      {"room", "Matrix room ID (e.g. `!example:homeserver.com`)"}
    ],
    ok: """
    %{
      "tags" => %{
        "example" => {
          "order" => 0.1
        }
      }
    }
    """,
    errors: [],
    notes: [
      "Not ratelimited",
      "Authentication required"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#get-/_matrix/client/v3/user/-userId-/rooms/-roomId-/tags"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#get_matrixclientv3useruseridroomsroomidtags"}
    ]
  )

  @spec get_room_user_tags(api(), String.t(), String.t()) :: response()
  def get_room_user_tags(api, user, room) do
    Client.get(api, "#{@user_endpoint}/#{user}/rooms/#{room}/tags")
  end

  api_doc("
  Adds a tag to a room.
  ",
    parameters: [
      {"user", "Matrix user ID (e.g. `@example:homeserver.com`)"},
      {"room", "Matrix room ID (e.g. `!example:homeserver.com`)"},
      {"tag", "Tag to add"},
      {"data", "Elixir map of the extra data for the tag"}
    ],
    ok: "%{}",
    errors: [],
    notes: [
      "Not ratelimited",
      "Authentication required"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#put-/_matrix/client/v3/user/-userId-/rooms/-roomId-/tags/-tag-"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#put_matrixclientv3useruseridroomsroomidtagstag"}
    ]
  )

  @spec add_room_user_tag(
          api(),
          String.t(),
          String.t(),
          String.t(),
          map()
        ) :: response()
  def add_room_user_tag(api, user, room, tag, data) do
    Client.put(
      api,
      "#{@user_endpoint}/#{user}/rooms/#{room}/tags/#{tag}",
      JSON.encode_to_iodata!(data)
    )
  end

  api_doc("
  Removes a tag from the room.
  ",
    parameters: [
      {"user", "Matrix user ID (e.g. `@example:homeserver.com`)"},
      {"room", "Matrix room ID (e.g. `!example:homeserver.com`)"},
      {"tag", "Tag to remove"}
    ],
    ok: "%{}",
    errors: [],
    notes: [
      "Not ratelimited",
      "Authentication required"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#delete-/_matrix/client/v3/user/-userId-/rooms/-roomId-/tags/-tag-"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#delete_matrixclientv3useruseridroomsroomidtagstag"}
    ]
  )

  @spec remove_room_user_tag(api(), String.t(), String.t(), String.t()) :: response()
  def remove_room_user_tag(api, user, room, tag) do
    Client.delete(
      api,
      "#{@user_endpoint}/#{user}/rooms/#{room}/tags/#{tag}"
    )
  end
end
