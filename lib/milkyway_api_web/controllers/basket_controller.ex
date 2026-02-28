defmodule MilkywayApiWeb.BasketController do
  use MilkywayApiWeb, :controller

  alias MilkywayApi.Catalog
  alias MilkywayApi.Orders

  def index(conn, _params) do
    user = conn.assigns[:current_user]

    with {:ok, user} <- require_auth(user),
         :ok <- require_buyer(user) do
      basket_products = Orders.list_basket_products_for_buyer(user.id)
      json(conn, %{data: basket_products})
    else
      {:error, status, message} ->
        conn |> put_status(status) |> json(%{error: message})
    end
  end

  def create(conn, %{"id" => product_id}) do
    user = conn.assigns[:current_user]

    with {:ok, user} <- require_auth(user),
         :ok <- require_buyer(user),
         product <- Catalog.get_product!(product_id),
         :ok <- forbid_owner(user, product.seller_id) do
      case Orders.add_to_basket(%{buyer_id: user.id, product_id: product.id}) do
        {:ok, _basket_item} ->
          conn
          |> put_status(:created)
          |> json(%{data: product})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "validation_failed", details: changeset_errors(changeset)})
      end
    else
      {:error, status, message} ->
        conn |> put_status(status) |> json(%{error: message})
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns[:current_user]

    with {:ok, user} <- require_auth(user),
         :ok <- require_buyer(user),
         basket_item <- Orders.get_basket_item(id),
         :ok <- verify_not_nil(basket_item),
         :ok <- require_owner(user, basket_item.buyer_id) do
      Orders.delete_basket_item(basket_item)
      send_resp(conn, :no_content, "")
    else
      {:error, status, message} ->
        conn |> put_status(status) |> json(%{error: message})
    end
  end

  defp require_auth(nil), do: {:error, :unauthorized, "unauthorized"}
  defp require_auth(user), do: {:ok, user}

  defp require_buyer(%{role: "buyer"}), do: :ok
  defp require_buyer(_), do: {:error, :forbidden, "buyer_only"}

  defp forbid_owner(user, seller_id) do
    if user.id == seller_id, do: {:error, :forbidden, "cannot_buy_own_product"}, else: :ok
  end

  defp require_owner(user, owner_id) do
    if user.id == owner_id, do: :ok, else: {:error, :forbidden, "not_owner"}
  end

  defp verify_not_nil(nil), do: {:error, :not_found, "not_found"}
  defp verify_not_nil(_), do: :ok

  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {k, v}, acc ->
        String.replace(acc, "%{#{k}}", to_string(v))
      end)
    end)
  end
end
