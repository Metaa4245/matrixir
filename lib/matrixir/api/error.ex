defmodule Matrixir.API.Error do
  @moduledoc """
  A representation of a Matrix API error.
  """

  defstruct [
    :error_type,
    :error_string,

    # only on M_LIMIT_EXCEEDED :limit_exceeded
    :retry_after,

    # only on M_UNKNOWN_TOKEN :unknown_token
    :soft_logout,

    # only on M_RESOURCE_LIMIT_EXCEEDED :resource_limit_exceeded
    :admin_contact
  ]

  @typedoc """
  Atoms for each Matrix error type.

  `M_FORBIDDEN :forbidden` Forbidden access.

  `M_UNKNOWN_TOKEN :unknown_token` The access or refresh token specified was
  not recognized.

  `M_MISSING_TOKEN :missing_token` No access token was specified for the
  request.

  `M_USER_LOCKED :user_locked` The account has been locked and cannot be used
  at this time.

  `M_USER_SUSPENDED :user_suspended` The account has been suspended and can
  only be used for limited actions at this time.

  `M_BAD_JSON :bad_json` Request contained valid JSON, but it was malformed in
  some way.

  `M_NOT_JSON :not_json` Request did not contain valid JSON.

  `M_LIMIT_EXCEEDED :limit_exceeded` Too many requests have been sent in a
  short period of time. Wait a while then try again. (Ratelimited).

  `M_UNRECOGNIZED :unrecognized` The server did not understand the request.

  `M_UNAUTHORIZED :unauthorized` The request was not correctly authorized.

  `M_USER_DEACTIVATED :user_deactivated` The user ID has been deactivated.

  `M_USER_IN_USE :user_in_use` The user ID has been taken.

  `M_INVALID_USERNAME :invalid_username` The user ID is not valid.

  `M_ROOM_IN_USE :room_in_use` The room alias is already in use.

  `M_INVALID_ROOM_STATE :invalid_room_state` The initial room state is invalid.

  `M_THREEPID_IN_USE :threepid_in_use` The threepid is already in use.

  `M_THREEPID_NOT_FOUND :threepid_not_found` No record matching the threepid
  was found.

  `M_THREEPID_AUTH_FAILED :threepid_auth_failed` Authentication could not be
  performed on the third-party identifier.

  `M_THREEPID_DENIED :threepid_denied` The server does not permit this
  third-party identifier.

  `M_SERVER_NOT_TRUSTED :server_not_trusted` The client’s request used a
  third-party server.

  `M_UNSUPPORTED_ROOM_VERSION :unsupported_room_version` The client’s request
  to create a room used a room version that the server does not support.

  `M_INCOMPATIBLE_ROOM_VERSION :incompatible_room_version` The client attempted
  to join a room that has a version the server does not support.

  `M_BAD_STATE :bad_state` The state change requested cannot be performed.

  `M_GUEST_ACCESS_FORBIDDEN :guest_access_forbidden` The room or resource does
  not permit guests to access it.

  `M_CAPTCHA_NEEDED :captcha_needed` A CAPTCHA is required to complete the
  request.

  `M_CAPTCHA_INVALID :captcha_invalid` The CAPTCHA provided did not match what
  was expected.

  `M_MISSING_PARAM :missing_parameter` A required parameter was missing from
  the request.

  `M_INVALID_PARAM :invalid_parameter` A parameter that was specified has the
  wrong value.

  `M_TOO_LARGE :too_large` The request or entity was too large.

  `M_EXCLUSIVE :exclusive` The resource being requested is reserved by an
  application service, or the application service making the request has not
  created the resource.

  `M_RESOURCE_LIMIT_EXCEEDED :resource_limited_exceeded` The request cannot be
  completed because the homeserver has reached a resource limit imposed on it.

  `M_CANNOT_LEAVE_SERVER_NOTICE_ROOM :cannot_leave_server_notice_room` The user
  is unable to reject an invite to join the server notices room.

  `M_THREEPID_MEDIUM_NOT_SUPPORTED :threepid_medium_not_supported` The
  homeserver does not support adding a third party identifier of the given
  medium.

  `M_UNKNOWN :unknown` An unknown error has occurred.
  """
  @type error_type ::
          :forbidden
          | :unknown_token
          | :missing_token
          | :user_locked
          | :user_suspended
          | :bad_json
          | :not_json
          | :not_found
          | :limit_exceeded
          | :unrecognized
          | :unauthorized
          | :user_deactivated
          | :user_in_use
          | :invalid_username
          | :room_in_use
          | :invalid_room_state
          | :threepid_in_use
          | :threepid_not_found
          | :threepid_auth_failed
          | :threepid_denied
          | :server_not_trusted
          | :unsupported_room_version
          | :incompatible_room_version
          | :bad_state
          | :guest_access_forbidden
          | :captcha_needed
          | :captcha_invalid
          | :missing_parameter
          | :invalid_parameter
          | :too_large
          | :exclusive
          | :resource_limit_exceeded
          | :cannot_leave_server_notice_room
          | :threepid_medium_not_supported
          | :unknown

  @typedoc """
  Represents the JSON error returned by Matrix.

  `error_type` is an `t:error_type/0`.

  `error_string` is the human readable version of the error returned by Matrix.

  `retry_after` is a `t:Duration.t/0` returned by Matrix representing a
  duration in milliseconds to retry after specifically for
  `M_LIMIT_EXCEEDED :limit_exceeded` errors.

  `soft_logout` is on `M_UNKNOWN_TOKEN :unknown_token` errors signifying that
  the client should soft logout. A client can be in a “soft logout” state if
  the server requires re-authentication before continuing, but does not want
  to invalidate the client’s session.

  `admin_contact` is on `M_RESOURCE_LIMITED_EXCEEDED :resource_limit_exceeded`
  errors for contacting the admin.
  """
  @type t :: %__MODULE__{
          error_type: error_type(),
          error_string: String.t(),
          retry_after: Duration.t() | nil,
          soft_logout: boolean(),
          admin_contact: String.t()
        }

  @doc """
  Convert a `t:String.t/0` into an `t:error_type/0`.
  """
  @spec type_from_string(String.t()) :: error_type()
  def type_from_string(string) do
    case string do
      "M_FORBIDDEN" -> :forbidden
      "M_UNKNOWN_TOKEN" -> :unknown_token
      "M_MISSING_TOKEN" -> :missing_token
      "M_USER_LOCKED" -> :user_locked
      "M_USER_SUSPENDED" -> :user_suspended
      "M_BAD_JSON" -> :bad_json
      "M_NOT_JSON" -> :not_json
      "M_NOT_FOUND" -> :not_found
      "M_LIMIT_EXCEEDED" -> :limit_exceeded
      "M_UNRECOGNIZED" -> :unrecognized
      "M_UNAUTHORIZED" -> :unauthorized
      "M_USER_DEACTIVATED" -> :user_deactivated
      "M_USER_IN_USE" -> :user_in_use
      "M_INVALID_USERNAME" -> :invalid_username
      "M_ROOM_IN_USE" -> :room_in_use
      "M_INVALID_ROOM_STATE" -> :invalid_room_state
      "M_THREEPID_IN_USE" -> :threepid_in_use
      "M_THREEPID_NOT_FOUND" -> :threepid_not_found
      "M_THREEPID_AUTH_FAILED" -> :threepid_auth_failed
      "M_THREEPID_DENIED" -> :threepid_denied
      "M_SERVER_NOT_TRUSTED" -> :server_not_trusted
      "M_UNSUPPORTED_ROOM_VERSION" -> :unsupported_room_version
      "M_INCOMPATIBLE_ROOM_VERSION" -> :incompatible_room_version
      "M_BAD_STATE" -> :bad_state
      "M_GUEST_ACCESS_FORBIDDEN" -> :guest_access_forbidden
      "M_CAPTCHA_NEEDED" -> :captcha_needed
      "M_CAPTCHA_INVALID" -> :captcha_invalid
      "M_MISSING_PARAM" -> :missing_parameter
      "M_INVALID_PARAM" -> :invalid_parameter
      "M_TOO_LARGE" -> :too_large
      "M_EXCLUSIVE" -> :exclusive
      "M_RESOURCE_LIMIT_EXCEEDED" -> :resource_limited_exceeded
      "M_CANNOT_LEAVE_SERVER_NOTICE_ROOM" -> :cannot_leave_server_notice_room
      "M_THREEPID_MEDIUM_NOT_SUPPORTED" -> :threepid_medium_not_supported
      _ -> :unknown
    end
  end

  @spec from_json(map()) :: t()
  def from_json(data) do
    retry_after =
      case data[:retry_after_ms] do
        nil -> nil
        x -> Duration.new!(microsecond: {x, 3})
      end

    soft_logout =
      case data[:soft_logout] do
        nil -> false
        x -> x
      end

    admin_contact =
      case data[:admin_contact] do
        nil -> ""
        x -> x
      end

    %__MODULE__{
      error_type: type_from_string(data["errcode"]),
      error_string: data["error"],
      retry_after: retry_after,
      soft_logout: soft_logout,
      admin_contact: admin_contact
    }
  end
end
