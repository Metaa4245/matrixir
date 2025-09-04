defmodule Matrixir.API.Presence do
  @moduledoc """
  Matrix presence endpoints.
  """

  @typedoc """
  Alias for `t:Matrixir.API.response/0`.
  """
  @type response :: Matrixir.API.response()

  @typedoc """
  Alias for `t:Matrixir.API.t/0`.
  """
  @type api :: Matrixir.API.t()

  @presence_endpoint "/_matrix/client/v3/presence"

  alias Matrixir.API.Client
  import Matrixir.DocHelpers

  api_doc("
  Get the user's presence state.
  ",
    parameters: [
      {"user", "Matrix user ID (e.g. `@example:homeserver.com`)"}
    ],
    ok: """
    %{
      currently_active: false,  # can be nil
      last_active_ago: 80085,   # can be nil, in milliseconds
      presence: "unavailable",  # cannot be nil, "unavailable" | "offline" | "online"
      status_msg: "example"     # can be nil
    }
    """,
    errors: [
      {"You are not allowed to see the user's presence status.",
       """
         error_type: :forbidden,
         error_string: "You are not allowed to see their presence"
       """},
      {"There is no presence state for the user. The user may not exist or isn't exposing presence information to you.",
       """
         error_type: :unknown,
         error_string: "An unknown error occurred"
       """}
    ],
    notes: [
      "Not ratelimited",
      "Authentication required"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#get-/_matrix/client/v3/presence/-userId-/status"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#get_matrixclientv3presenceuseridstatus"}
    ]
  )

  @spec get_user_presence(api(), String.t()) :: response()
  def get_user_presence(api, user) do
    Client.get(api, "#{@presence_endpoint}/#{user}/status")
  end

  api_doc("
  Sets the user's presence state.",
    parameters: [
      {"user", "Matrix user ID (e.g. `@example:homeserver.com`)"},
      {"presence", "Presence (\"unavailable\" | \"offline\" | \"offline\")"},
      {"status_message", "Status message to attach to the state (optional, default `nil`)"}
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
      "Requires authentication"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#put-/_matrix/client/v3/presence/-userId-/status"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#put_matrixclientv3presenceuseridstatus"}
    ]
  )

  @spec set_user_presence(
          api(),
          String.t(),
          String.t(),
          String.t() | nil
        ) :: response()
  def set_user_presence(api, user, presence, status_message \\ nil) do
    Client.put(
      api,
      "#{@presence_endpoint}/#{user}/status",
      JSON.encode!(
        %{
          "presence" => presence,
          "status_msg" => status_message
        }
        |> Map.reject(fn x -> is_nil(x) end)
      )
    )
  end
end
