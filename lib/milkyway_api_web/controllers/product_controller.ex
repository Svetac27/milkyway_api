defmodule MilkywayApiWeb.ProductController do
  use MilkywayApiWeb, :controller

  alias MilkywayApi.Catalog
  alias MilkywayApi.Catalog.Product
  alias MilkywayApi.Orders

  # Public: list
  def index(conn, _params) do
    products = Catalog.list_products()
    json(conn, %{data: products})
  end

  # Public: show
  def show(conn, %{"id" => id}) do
    product = Catalog.get_product!(id)
    json(conn, %{data: product})
  end

  # Seller-only: create
  def create(conn, params) do
    user = conn.assigns[:current_user]

    with {:ok, user} <- require_auth(user),
         :ok <- require_seller(user) do
      attrs =
        params
        |> Map.take(["title", "description", "price", "status", "location"])
        |> Map.put("seller_id", user.id)

      case Catalog.create_product(attrs) do
        {:ok, %Product{} = product} ->
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

  # Seller-only + ownership: update
  def update(conn, %{"id" => id} = params) do
    user = conn.assigns[:current_user]

    with {:ok, user} <- require_auth(user),
         :ok <- require_seller(user),
         product <- Catalog.get_product!(id),
         :ok <- require_owner(user, product) do
      attrs = Map.take(params, ["title", "description", "price", "status", "location"])

      case Catalog.update_product(product, attrs) do
        {:ok, %Product{} = product} ->
          json(conn, %{data: product})

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

  # Seller-only + ownership: delete
  def delete(conn, %{"id" => id}) do
    user = conn.assigns[:current_user]

    with {:ok, user} <- require_auth(user),
         :ok <- require_seller(user),
         product <- Catalog.get_product!(id),
         :ok <- require_owner(user, product) do
      {:ok, _} = Catalog.delete_product(product)
      send_resp(conn, :no_content, "")
    else
      {:error, status, message} ->
        conn |> put_status(status) |> json(%{error: message})
    end
  end

  # Seller-only + ownership: list buyers who selected product in basket
  def buyers(conn, %{"id" => id}) do
    user = conn.assigns[:current_user]

    with {:ok, user} <- require_auth(user),
         :ok <- require_seller(user),
         product <- Catalog.get_product!(id),
         :ok <- require_owner(user, product) do
      buyers = Orders.list_buyers_for_product(product.id)

      json(conn, %{data: Enum.map(buyers, &serialize_user/1)})
    else
      {:error, status, message} ->
        conn |> put_status(status) |> json(%{error: message})
    end
  end

  # ---- helpers ----

  defp require_auth(nil), do: {:error, :unauthorized, "unauthorized"}
  defp require_auth(user), do: {:ok, user}

  defp require_seller(%{role: "seller"}), do: :ok
  defp require_seller(_), do: {:error, :forbidden, "seller_only"}

  defp require_owner(user, %Product{seller_id: seller_id}) do
    if user.id == seller_id, do: :ok, else: {:error, :forbidden, "not_owner"}
  end

  defp serialize_user(user) do
    %{
      id: user.id,
      email: user.email,
      role: user.role,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {k, v}, acc ->
        String.replace(acc, "%{#{k}}", to_string(v))
      end)
    end)
  end
end
