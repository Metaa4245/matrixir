defmodule Matrixir.DocHelpers do
  @moduledoc false

  defp indent(string, n \\ 2) do
    string
    |> String.split("\n")
    |> Enum.map_join("\n", &"#{String.duplicate(" ", n)}#{&1}")
  end

  defp exampler(string, trim?) do
    string = indent(string)
    if trim?, do: String.trim(string), else: string
  end

  defmacro api_doc(summary, opts) do
    parameters = Keyword.get(opts, :parameters, [])
    ok_example = Keyword.get(opts, :ok, nil)
    errors = Keyword.get(opts, :errors, [])
    notes = Keyword.get(opts, :notes, [])
    references = Keyword.get(opts, :references, [])

    parameters_doc =
      [
        "- `api` - `t:Matrixir.API.t/0` struct"
        | Enum.map(parameters, fn {name, desc} -> "- `#{name}` - #{desc}" end)
      ]
      |> Enum.join("\n")

    ok_doc = """
    - Successful request.
      ```elixir
      {:ok, #{ok_example |> exampler(true)}}
      ```
    """

    errors_doc =
      Enum.map_join(errors, "\n\n", fn {summary, example} ->
        "- #{summary}\n```elixir\n{:error, %Matrixir.API.Error{\n#{example |> exampler(false)}}}\n```\n"
      end)

    generic_error_doc = """
    - Other error, see `Matrixir.Error`.
      Note: this is distinct from `Matrixir.API.Error`.
      ```elixir
      {:error, %Matrixir.Error{}}
      ```
    """

    notes_doc =
      Enum.map_join(notes, "\n", &"- #{&1}")

    references_doc =
      Enum.map_join(references, "\n", fn {label, url} -> "- [#{label}](#{url})" end)

    full_doc = """
    #{summary}

    ## Parameters
    #{parameters_doc}

    ## Return values
    #{ok_doc}

    #{errors_doc}

    #{generic_error_doc}

    ## Notes
    #{notes_doc}

    ## See also
    #{references_doc}
    """

    quote do
      @doc unquote(full_doc)
    end
  end
end
