defmodule Matrixir.API.RoomUpgrade do
  @moduledoc """
  Matrix room upgrade endpoints.
  """

  @typedoc """
  Alias for `t:Matrixir.API.response/0`.
  """
  @type response :: Matrixir.API.response()

  @typedoc """
  Alias for `t:Matrixir.API.t/0`.
  """
  @type api :: Matrixir.API.t()

  @room_endpoint "/_matrix/client/v3/rooms"

  import Matrixir.DocHelpers
  alias Matrixir.API.Client

  api_doc("Upgrades a room to a new version.",
    parameters: [
      {"room", "Matrix room ID (e.g. `!example:homeserver.com`)"},
      {"version", "New room version"}
    ],
    ok: """
    %{
      "replacement_room" => "!example:homeserver.com" # optional
    }
    """,
    errors: [
      {"The room version requested is not supported by the homeserver.",
       """
         error_type: :unsupported_room_version,
         error_string: "This server does not support that room version" # optional
       """},
      {"The user is not permitted to upgrade the room.",
       """
         error_type: :forbidden,
         error_string: "You cannot upgrade this room" # optional
       """}
    ],
    notes: [
      "Authentication required",
      "Not rate-limited"
    ],
    references: [
      {"Playground",
       "https://playground.matrix.org/#post-/_matrix/client/v3/rooms/-roomId-/upgrade"},
      {"Specification",
       "https://spec.matrix.org/v1.15/client-server-api/#post_matrixclientv3roomsroomidupgrade"}
    ]
  )

  @spec upgrade_room(api(), String.t(), String.t()) :: response()
  def upgrade_room(api, room, version) do
    Client.post(
      api,
      "#{@room_endpoint}/#{room}/upgrade",
      JSON.encode_to_iodata!(%{
        "new_version" => version
      })
    )
  end
end
