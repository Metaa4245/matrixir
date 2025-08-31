defmodule Matrixir.Error do
  @moduledoc """
  Matrixir Errors.
  """

  defstruct [:type, :reason]

  @type t :: %__MODULE__{
          type: :http | :decode | :matrix | :other,
          reason: term()
        }

  def new(type, reason) do
    %__MODULE__{
      type: type,
      reason: reason
    }
  end
end
