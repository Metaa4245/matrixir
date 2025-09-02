defmodule Matrixir.API.UserData do
  @moduledoc """
  Matrix user data endpoints.
  """

  @typedoc """
  Shortening of `t:Matrixir.API.response/0`.
  """
  @type response :: Matrixir.API.response()

  @typedoc """
  Shortening of `t:Matrixir.API.t/0`.
  """
  @type api :: Matrixir.API.t()

  @profile_endpoint "/_matrix/client/v3/profile"
  @user_endpoint "/_matrix/client/v3/user"

  alias Matrixir.API.Client

  @doc """
  Get the user's profile information, consisting of the avatar URL and the
  display name. This API can be used to fetch either the current user's or
  other user's profile information, either locally or on remote homeservers.

  The user is a user ID in the form of a Matrix user ID,
  `@name:homeserver.com`.

  Returns a 200 OK with a JSON such as:
  ```json
  {
    "avatar_url": "mxc://matrix.org/SDGdghriugerRg",
    "displayname": "Alice Margatroid"
  }
  ```

  Returns a 403 Forbidden when the server is unwilling to disclose
  whether the user exists and/or has profile information.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_FORBIDDEN",
    "error": "Profile lookup is disabled on this homeserver"
  }
  ```

  Returns a 404 Not Found when there is no profile information for
  the user or the user does not exist.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_NOT_FOUND",
    "error": "Profile not found"
  }
  ```
  """
  @spec get_user_info(api(), String.t()) :: response()
  def get_user_info(api, user) do
    Client.get(api, "#{@profile_endpoint}/#{user}")
  end

  @doc """
  Get the user's avatar URL. This API can be used to fetch either the current
  user's or other user's avatar URL, either locally or on remote homeservers.

  The user is a user ID in the form of a Matrix user ID,
  `@name:homeserver.com`.

  Returns a 200 OK with a JSON such as:
  ```json
  {
    "avatar_url": "mxc://matrix.org/SDGdghriugerRg"
  }
  ```

  Returns a 403 Forbidden when the server is unwilling to disclose
  whether the user exists and/or has an avatar URL.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_FORBIDDEN",
    "error": "Profile lookup is disabled on this homeserver"
  }
  ```

  Returns a 404 Not Found when there is no avatar URL for the user
  or the user does not exist.
  The error reason is 404.
  """
  @spec get_user_avatar(api(), String.t()) :: response()
  def get_user_avatar(api, user) do
    Client.get(api, "#{@profile_endpoint}/#{user}/avatar_url")
  end

  @doc """
  Get the user's display name. This API can be used to fetch either the current
  user's or other user's display name, either locally or on remote homeservers.

  The user is a user ID in the form of a Matrix user ID,
  `@name:homeserver.com`.

  Returns a 200 OK with a JSON such as:
  ```json
  {
    "displayname": "Alice Margatroid"
  }
  ```

  Returns a 403 Forbidden when the server is unwilling to disclose
  whether the user exists and/or has an display name.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_FORBIDDEN",
    "error": "Profile lookup is disabled on this homeserver"
  }
  ```

  Returns a 404 Not Found when there is no display name for the user
  or the user does not exist.
  The error reason is 404.
  """
  @spec get_user_display_name(api(), String.t()) :: response()
  def get_user_display_name(api, user) do
    Client.get(api, "#{@profile_endpoint}/#{user}/displayname")
  end

  @doc """
  Get some account data for the client.
  This API is only usable for the user that set the account data.

  The user is a user ID in the form of a Matrix user ID,
  `@name:homeserver.com`, where the access token is
  authorized to make requests for this user.

  The event type is the type of account data to get.
  Custom types should be namespaced to avoid clashes.

  Returns a 200 OK with a JSON such as:
  ```json
  {
    "custom_account_data_key": "custom_config_value"
  }
  ```

  Returns a 403 Forbidden when the access token provided is not authorized to
  retrieve this user's account data.
  The error code is `M_FORBIDDEN`.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_FORBIDDEN",
    "error": "Cannot add account data for other users."
  }
  ```

  Returns a 404 Not Found when no account data has been provided for this user
  with the given `type`.
  The error code is `M_NOT_FOUND`.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_NOT_FOUND",
    "error": "Account data not found."
  }
  ```
  """
  @spec get_user_data(api(), String.t(), String.t()) :: response()
  def get_user_data(api, user, type) do
    Client.get(api, "#{@user_endpoint}/#{user}/account_data/#{type}")
  end

  @doc """
  Get some account data for the client on a given room.
  This API is only usable for the user that set the account data.

  The user is a user ID in the form of a Matrix user ID,
  `@name:homeserver.com`, where the access token is
  authorized to make requests for this user.

  The room is a room ID in the form of a Matrix room ID,
  `!randomid:homeserver.com`.

  The event type is the type of account data to get.
  Custom types should be namespaced to avoid clashes.

  Returns a 200 OK with a JSON such as:
  ```json
  {
    "custom_account_data_key": "custom_config_value"
  }
  ```

  Returns a 400 Bad Request when the given room is not a valid room.
  The error code is `M_INVALID_PARAM`.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_INVALID_PARAM",
    "error": "@notaroomid:example.org is not a valid room ID."
  }
  ```

  Returns a 403 Forbidden when the access token provided is not authorized to
  retrieve this user's account data.
  The error code is `M_FORBIDDEN`.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_FORBIDDEN",
    "error": "Cannot add account data for other users."
  }
  ```

  Returns a 404 Not Found when no account data has been provided for this user
  and this room with the given `type`.
  The error code is `M_NOT_FOUND`.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_NOT_FOUND",
    "error": "Room account data not found."
  }
  ```
  """
  @spec get_room_user_data(api(), String.t(), String.t(), String.t()) :: response()
  def get_room_user_data(api, user, room, type) do
    Client.get(
      api,
      "#{@user_endpoint}/#{user}/rooms/#{room}/account_data/#{type}"
    )
  end

  @doc """
  Set the user's avatar URL. You must have permission to set this user's avatar
  URL, for example having their access token.

  The user is a user ID in the form of a Matrix user ID,
  `@name:homeserver.com`, where the access token is
  authorized to make requests for this user.

  The avatar URL gets serialized into the following JSON:
  ```json
  {
    "avatar_url": "avatar"
  }
  ```

  Returns a 200 OK with an empty JSON body when the avatar URL was set.

  Returns a 429 when the request was ratelimited.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_LIMIT_EXCEEDED",
    "error": "Too many requests",
    "retry_after_ms": 2000
  }
  ```
  """
  @spec set_user_avatar(api(), String.t(), String.t()) :: response()
  def set_user_avatar(api, user, avatar) do
    Client.put(
      api,
      "#{@profile_endpoint}/#{user}/avatar_url",
      JSON.encode!(%{avatar_url: avatar})
    )
  end

  @doc """
  Set the user's display name. You must have permission to set this user's
  display name, for example having their access token.

  The user is a user ID in the form of a Matrix user ID,
  `@name:homeserver.com`, where the access token is
  authorized to make requests for this user.

  The display name gets serialized into the following JSON:
  ```json
  {
    "displayname": "display_name"
  }
  ```

  Returns a 200 OK with an empty JSON body when the display name was set.

  Returns a 429 when the request was ratelimited.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_LIMIT_EXCEEDED",
    "error": "Too many requests",
    "retry_after_ms": 2000
  }
  ```
  """
  @spec set_user_display_name(api(), String.t(), String.t()) :: response()
  def set_user_display_name(api, user, display_name) do
    Client.put(
      api,
      "#{@profile_endpoint}/#{user}/displayname",
      JSON.encode!(%{displayname: display_name})
    )
  end

  @doc """
  Set some account data for the client.
  This API is only usable for the user that set the account data.
  The account data will be available to clients through the top-level
  `account_data` field in the homeserver response to `/sync`.

  The user is a user ID in the form of a Matrix user ID,
  `@name:homeserver.com`, where the access token is
  authorized to make requests for this user.

  The event type is the type of account data to get.
  Custom types should be namespaced to avoid clashes.

  The data gets encoded into JSON, such as the following:
  ```json
  {
    "custom_account_data_key": "custom_config_value"
  }
  ```

  Returns a 200 OK with empty JSON if the account data was successfully added.

  Returns a 400 Bad Request if the body is not a JSON object.
  The error code is `M_BAD_JSON` or `M_NOT_JSON`.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_NOT_JSON",
    "error": "Content must be a JSON object."
  }
  ```

  Returns a 403 Forbidden when the access token provided is not authorized to
  modify this user's account data.
  The error code is `M_FORBIDDEN`.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_FORBIDDEN",
    "error": "Cannot add account data for other users."
  }
  ```

  Returns a 405 Method Not Allowed when this type of account data is controlled
  by the server and it cannot be modified by clients.
  The error code is `M_BAD_JSON`.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_BAD_JSON",
    "error": "Cannot set m.fully_read through this API."
  }
  ```
  """
  @spec set_user_data(api(), String.t(), String.t(), map()) :: response()
  def set_user_data(api, user, type, data) do
    Client.put(
      api,
      "#{@user_endpoint}/#{user}/account_data/#{type}",
      JSON.encode!(data)
    )
  end

  @doc """
  Set some account data for the client on a given room.
  This API is only usable for the user that set the account data.
  The account data will be delivered to clients in the per-room entries via
  `/sync`.

  The user is a user ID in the form of a Matrix user ID,
  `@name:homeserver.com`, where the access token is
  authorized to make requests for this user.

  The room is a room ID in the form of a Matrix room ID,
  `!randomid:homeserver.com`.

  The event type is the type of account data to get.
  Custom types should be namespaced to avoid clashes.

  The data gets encoded into JSON, such as the following:
  ```json
  {
    "custom_account_data_key": "custom_config_value"
  }
  ```

  Returns a 200 OK with empty JSON if the account data was successfully added.

  Returns a 400 Bad Request if the body is not a JSON object, or if the room is
  not a valid room ID.
  The error code is `M_BAD_JSON` or `M_NOT_JSON` when the body is not JSON.
  The error code is `M_INVALID_PARAM` when the room is not a valid room ID.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_NOT_JSON",
    "error": "Content must be a JSON object."
  }
  ```

  Returns a 403 Forbidden when the access token provided is not authorized to
  modify this user's account data.
  The error code is `M_FORBIDDEN`.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_FORBIDDEN",
    "error": "Cannot add account data for other users."
  }
  ```

  Returns a 405 Method Not Allowed when this type of account data is controlled
  by the server and it cannot be modified by clients.
  The error code is `M_BAD_JSON`.
  The error reason is a JSON such as:
  ```json
  {
    "errcode": "M_BAD_JSON",
    "error": "Cannot set m.fully_read through this API."
  }
  ```
  """
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
      JSON.encode!(data)
    )
  end

  @doc """
  Gets the tags set by a user on a room.

  The user is a user ID in the form of a Matrix user ID,
  `@name:homeserver.com`, where the access token is
  authorized to make requests for this user.

  The room is a room ID in the form of a Matrix room ID,
  `!randomid:homeserver.com`.

  Returns a 200 OK with a JSON such as the following:
  ```json
  {
    "tags": {
      "m.favourite": {
        "order": 0.1
      },
      "u.Customers": {},
      "u.Work": {
        "order": 0.7
      }
    }
  }
  ```
  """
  @spec get_room_user_tags(api(), String.t(), String.t()) :: response()
  def get_room_user_tags(api, user, room) do
    Client.get(api, "#{@user_endpoint}/#{user}/rooms/#{room}/tags")
  end

  # TODO: data: is it only order and thus i can get away with order?
  # or can tags have custom data? idk matrix tags
  @doc """
  Adds a tag to a room.

  The user is a user ID in the form of a Matrix user ID,
  `@name:homeserver.com`, where the access token is
  authorized to make requests for this user.

  The room is a room ID in the form of a Matrix room ID,
  `!randomid:homeserver.com`.

  The tag is the tag to add.

  The data is JSON such as the following, with for example ordering:
  ```json
  {
    "order": 0.25
  }
  ```

  Returns a 200 OK with an empty JSON body.
  """
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
      JSON.encode!(data)
    )
  end

  @doc """
  Remove a tag from the room.

  The user is a user ID in the form of a Matrix user ID,
  `@name:homeserver.com`, where the access token is
  authorized to make requests for this user.

  The room is a room ID in the form of a Matrix room ID,
  `!randomid:homeserver.com`.

  The tag is the tag to remove.

  Returns a 200 OK with an empty JSON body.
  """
  @spec remove_room_user_tag(api(), String.t(), String.t(), String.t()) :: response()
  def remove_room_user_tag(api, user, room, tag) do
    Client.delete(
      api,
      "#{@user_endpoint}/#{user}/rooms/#{room}/tags/#{tag}"
    )
  end
end
