defmodule ExBitmex.Rest.Margins do
  alias ExBitmex.Rest

  @type credentials :: ExBitmex.Credentials.t() | nil
  @type params :: map
  @type position :: ExBitmex.Margin.t()
  @type rate_limit :: ExBitmex.RateLimit.t()

  def list(%ExBitmex.Credentials{} = credentials, params \\ %{}) do
    "/user/margin"
    |> Rest.HTTPClient.auth_get(credentials, params)
    |> parse_response
  end

  defp parse_response({:ok, data, rate_limit}) when is_list(data) do
    positions =
      data
      |> Enum.map(&to_struct/1)
      |> Enum.map(fn {:ok, p} -> p end)

    {:ok, positions, rate_limit}
  end

  defp parse_response({:ok, data, rate_limit}) when is_map(data) do
    {:ok, order} = data |> to_struct
    {:ok, order, rate_limit}
  end

  defp parse_response({:error, _, _} = error), do: error

  defp to_struct(data) do
    data
    |> Mapail.map_to_struct(
      ExBitmex.Margin,
      transformations: [:snake_case]
    )
  end
end
