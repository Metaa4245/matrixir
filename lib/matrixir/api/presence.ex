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
      "currently_active" => false,  # optional
      "last_active_ago" => 80085,   # optional, milliseconds
      "presence" => "unavailable",  # "unavailable" | "offline" | "online"
      "status_msg" => "example"     # optional
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
      "Authentication required",
      "Not rate-limited"
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
      "Authentication required",
      "Rate-limited"
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
      JSON.encode_to_iodata!(
        %{
          "presence" => presence,
          "status_msg" => status_message
        }
        |> Map.reject(&is_nil/1)
      )
    )
  end
end
