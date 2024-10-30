defmodule WalletApiPariyWeb.ChangesetJSON do
  @doc """
  Renders changeset errors.
  """
    def error(%{changeset: changeset}) do
      errors = Ecto.Changeset.traverse_errors(changeset, &translate_error/1)

      error_messages =
        errors
        |> Enum.flat_map(fn {field, messages} ->
          Enum.map(messages, fn msg -> "#{field} #{msg}" end)
        end)

      status = if Enum.any?(error_messages, fn msg -> String.contains?(msg, "uuid has already been taken") end) do
        "RS_ERROR_DUPLICATE_TRANSACTION"
      else
        "RS_ERROR_WRONG_SYNTAX"
      end

      %{
        error: Enum.join(error_messages, ", "),
        status: status
      }
    end

  defp translate_error({msg, opts}) do
    # You can make use of gettext to translate error messages by
    # uncommenting and adjusting the following code:

    # if count = opts[:count] do
    #   Gettext.dngettext(WalletApiPariyWeb.Gettext, "errors", msg, msg, count, opts)
    # else
    #   Gettext.dgettext(WalletApiPariyWeb.Gettext, "errors", msg, opts)
    # end

    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
