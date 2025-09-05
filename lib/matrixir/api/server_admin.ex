defmodule Matrixir.API.ServerAdmin do
  @moduledoc """
  Matrix server admin endpoints.
  """

  @typedoc """
  Alias for `t:Matrixir.API.response/0`.
  """
  @type response :: Matrixir.API.response()

  @typedoc """
  Alias for `t:Matrixir.API.t/0`.
  """
  @type api :: Matrixir.API.t()

  @matrix_endpoint "/_matrix/client"
  @v1_endpoint "#{@matrix_endpoint}/v1"
  @v3_endpoint "#{@matrix_endpoint}/v3"

  @well_known_endpoint "./well-known/matrix"

  import Matrixir.DocHelpers
  alias Matrixir.API.Client

  api_doc("Fetches discovery information about the domain.",
    parameters: [],
    ok: """
    %{
      "m.homeserver" => %{
        "base_url" => "https://matrix.homeserver.com"
      },
      "m.identity_server" => %{
        "base_url" => "https://identity.homeserver.com"
      }
    }
    """,
    errors: [
      {"No server discovery information available. (404 Not Found)", ""}
    ],
    notes: [
      "Authentication not required",
      "Not rate-limited"
    ],
    references: [
      {"Playground", "https://playground.matrix.org/#get-/.well-known/matrix/client"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#getwell-knownmatrixclient"}
    ]
  )

  @spec get_discovery_info(api()) :: response()
  def get_discovery_info(api) do
    Client.get(api, "#{@well_known_endpoint}/client")
  end

  api_doc("Fetches server admin contact and support page of the domain.",
    parameters: [],
    ok: """
    %{
      "contacts" => [
        %{
          "email_address" => "admin@homeserver.com",
          "matrix_id" => "@admin:homeserver.com",
          "role" => "m.role.admin"
        },
        %{
          "email_address" => "security@homeserver.com",
          "role" => "m.role.security"
        }
      ],
      "support_page" => "https://homeserver.com/support.html"
    }
    """,
    errors: [
      {"No server support information available. (404 Not Found)", ""}
    ],
    notes: [
      "Authentication not required",
      "Not rate-limited"
    ],
    references: [
      {"Playground", "https://playground.matrix.org/#get-/.well-known/matrix/support"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#getwell-knownmatrixsupport"}
    ]
  )

  @spec get_support_info(api()) :: response()
  def get_support_info(api) do
    Client.get(api, "#{@well_known_endpoint}/support")
  end

  api_doc("Fetches information about a user.",
    parameters: [
      {"user", "Matrix user ID (e.g. `@example:homeserver.com`)"}
    ],
    ok: """
    %{
      "devices" => %{
        "example" => %{
          "sessions" => [
            %{
              "connections": [
                %{
                  "ip" => "127.0.0.1",
                  "last_seen" => 1411996332123,
                  "user_agent" => "example"
                }
              ]
            }
          ]
        }
      },
      "user_id" => "@example:homeserver.com"
    }
    """,
    errors: [],
    notes: [
      "Authentication required",
      "Not rate-limited"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#get-/_matrix/client/v3/admin/whois/-userId-"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#get_matrixclientv3adminwhoisuserid"}
    ]
  )

  @spec whois(api(), String.t()) :: response()
  def whois(api, user) do
    Client.get(api, "#{@v3_endpoint}/admin/whois/#{user}")
  end

  api_doc("Fetches the versions of the specification supported by the server.

  This can behave differently when authentication is provided.",
    parameters: [],
    ok: """
    %{
      "unstable_features" => %{
        "org.example.feature" => true
      },
      "versions" => [
        "r0.0.1",
        "v1.1"
      ]
    }
    """,
    errors: [],
    notes: [
      "Authentication optional",
      "Not rate-limited"
    ],
    references: [
      {"Playground", "https://playground.matrix.org/#get-/_matrix/client/versions"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#get_matrixclientversions"}
    ]
  )

  @spec get_spec_versions(api()) :: response()
  def get_spec_versions(api) do
    Client.get(api, "#{@matrix_endpoint}/versions")
  end

  api_doc("
  Asks the homeserver to call the `/_matrix/app/v1/ping` endpoint on the
  application service.

  This requires the use of an application service access token. The application
  service being pinged must be the same as the application service whose access
  token is being used.",
    parameters: [
      {"id", "Application service ID (e.g. `example`)"},
      {"transaction_id",
       "Optional transaction ID to pass to the application service. Defaults to `nil`."}
    ],
    ok: """
    %{
      "duration_ms" => 123
    }
    """,
    errors: [
      {"The application service doesn't have a URL configured.",
       """
         error_type: :url_not_set,
         error_string: "Application service doesn't have a URL configured"
       """},
      {"The access token used to authenticate the request doesn't belong to an application service, or belongs to a different application service than the one in the path.",
       """
         error_type: :forbidden,
         error_string: "Provided access token is not the appservice's as_token"
       """},
      {"The application service returned a bad status.",
       """
         error_type: :bad_status,
         error_string: "Ping returned status 401",

         body: "{\"errcode\": \"M_UNKNOWN_TOKEN\"}",
         status: 401
       """},
      {"The connection failed.",
       """
         error_type: :connection_failed,
         error_string: "Ping returned status 401" # speculative
       """},
      {"The connection to the application service timed out.",
       """
         error_type: :connection_timeout,
         error_string: "Connection to application service timed out"
       """}
    ],
    notes: [
      "Authentication required",
      "Not rate-limited"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#post-/_matrix/client/v1/appservice/-appserviceId-/ping"},
      {"Specification",
       "https://spec.matrix.org/v1.15/application-service-api/#post_matrixclientv1appserviceappserviceidping"}
    ]
  )

  @spec ping_app_service(api(), String.t(), String.t() | nil) :: response()
  def ping_app_service(api, id, transaction_id \\ nil) do
    Client.post(
      api,
      "#{@v1_endpoint}/appservice/#{id}/ping",
      JSON.encode_to_iodata!(
        %{transaction_id: transaction_id}
        |> Map.reject(&is_nil/1)
      )
    )
  end

  api_doc("Fetches a room summary.

  Requests for rooms where the user's membership is `invite` or `knock` might
  yield outdated, partial or even no data since the server may not have access
  to the current state of the room.

  Servers may allow unauthenticated access to this API if at least one of the
  following conditions holds true:

  - The room has a join rule of `public`, `knock` or `knock_restricted`.
  - The room has a `world_readable` history visibility.

  Servers may rate limit requests that require a federation request more
  heavily if the client is unauthenticated.
  ",
    parameters: [
      {"room",
       "Matrix room ID (e.g. `!example:homeserver.com`) or Matrix room alias (e.g. `#example:homeserver.com`)"},
      {"via",
       "Array of strings the server attempts to request the room summary from when the local server cannot generate it."}
    ],
    ok: """
    %{
      "avatar_url" => "mxc://homeserver.com/example",
      "encryption" => "m.megolm.v1.aes-sha2",
      "guest_can_join" => false,
      "join_rule" => "public",  # if not present, assumed "public"
      "membership" => "invite", # "invite" | "join" | "knock" | "leave" | "ban"
      "name" => "Example",
      "num_joined_numbers" => 1,
      "room_id" => "!example@homeserver.com",
      "room_type" => "m.space",
      "room_version" => "12",
      "topic" => "Example",    # omitted if no topic exists
      "world_readable" => true
    }
    """,
    errors: [
      {"The room could not be found.",
       """
         error_type: :not_found,
         error_string: "Room not found."
       """}
    ],
    notes: [
      "Authentication may be required",
      "Not rate-limited"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#get-/_matrix/client/v1/room_summary/-roomIdOrAlias-"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#get_matrixclientv1room_summaryroomidoralias"}
    ]
  )

  @spec get_room_summary(api(), String.t(), list(String.t())) :: response()
  def get_room_summary(api, room, via \\ []) do
    query = Enum.map_join(via, &"&via=#{&1}")

    Client.get(
      api,
      "#{@v1_endpoint}/room_summary/#{room}?via=#{api.base_url}#{query}"
    )
  end

  api_doc("Refreshes an access token.",
    parameters: [
      {"refresh_token", "The refresh token"}
    ],
    ok: """
    %{
      "access_token" => "new access token",
      "expires_in_ms" => 60000,
      "refresh_token" => "new refresh token"
    }
    """,
    errors: [
      {"The provided token was unknown, or has already been used.",
       """
         error_type: :unknown_token,
         error_string: "Soft logged out",

         soft_logout: true
       """},
      {"The request was rate-limited.",
       """
         error_type: :limit_exceeded,
         error_string: "Too many requests",

         retry_after: Duration
       """}
    ],
    notes: [
      "Authentication provided through `refresh_token`",
      "Rate-limited"
    ],
    references: [
      {"Playground", "https://playground.matrix.org/#post-/_matrix/client/v3/refresh"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#post_matrixclientv3refresh"}
    ]
  )

  @spec refresh_access_token(api(), String.t()) :: response()
  def refresh_access_token(api, refresh_token) do
    Client.post(
      api,
      "#{@v3_endpoint}/refresh",
      JSON.encode_to_iodata!(%{"refresh_token" => refresh_token})
    )
  end
end
