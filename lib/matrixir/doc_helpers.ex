defmodule Matrixir.DocHelpers do
  @moduledoc false

  defp indent(string, n \\ 2) do
    string
    |> String.split("\n")
    |> Enum.map_join("\n", fn line -> "#{String.duplicate(" ", n)}#{line}" end)
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
      Enum.map(parameters, fn {name, desc} -> "- `#{name}` - #{desc}" end)
      |> Enum.join("\n")

    ok_doc = """
    - Successful request.
      ```elixir
      {:ok, #{ok_example |> exampler(true)}}
      ```
    """

    errors_doc =
      errors
      |> Enum.map(fn {summary, example} ->
        "- #{summary}\n```elixir\n{:error, %Matrixir.API.Error{\n#{example |> exampler(false)}}}\n```\n"
      end)
      |> Enum.join("\n\n")

    generic_error_doc = """
    - Other error, see `Matrixir.Error`.
      Note: this is distinct from `Matrixir.API.Error`.
      ```elixir
      {:error, %Matrixir.Error{}}
      ```
    """

    notes_doc =
      Enum.map(notes, fn n -> "- " <> n end)
      |> Enum.join("\n")

    references_doc =
      Enum.map(references, fn {label, url} -> "- [#{label}](#{url})" end)
      |> Enum.join("\n")

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
