defmodule Matrixir.Error do
  @moduledoc """
  Matrixir errors.
  """

  defstruct [
    :type,
    :reason
  ]

  @typedoc """
  If the error type is of :http, then the error occurred in the Finch request.

  If the error type is of :decode, then the error occurred in the JSON decode.

  If the error type is of :matrix, then the error occurred in the
  Matrix API call.

  If the error type is of :other, then something else happened.
  Check error_reason.
  """
  @type error_type :: :http | :decode | :matrix | :other

  @typedoc """
  The reason for the error.

  The error reason in the case of an HTTP error is the Finch exception.

  The error reason in the case of a decode error is the JSON error.

  The error reason in the case of a Matrix API error is
  `Matrixir.API.Error.t/0` or (as in the case of a 404 Not Found), the HTTP
  status code.

  The error reason in the case of other error is the error.
  """
  @type error_reason :: term()

  @type t :: %__MODULE__{
          type: error_type(),
          reason: error_reason()
        }

  @doc false
  @spec __new__(error_type(), error_reason()) :: t()
  def __new__(type, reason) do
    %__MODULE__{
      type: type,
      reason: reason
    }
  end
end
