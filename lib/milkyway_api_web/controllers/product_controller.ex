defmodule MilkywayApiWeb.ProductController do
  use MilkywayApiWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias MilkywayApi.Catalog
  alias MilkywayApi.Catalog.Product
  alias MilkywayApi.Orders
  alias OpenApiSpex.Schema

  @product_properties %{
    id: %Schema{type: :integer},
    title: %Schema{type: :string},
    description: %Schema{type: :string},
    price: %Schema{type: :integer, description: "Price in cents"},
    status: %Schema{
      type: :string,
      enum: ["active", "reserved", "sold", "hidden"],
      description: "Product status"
    },
    location: %Schema{type: :string},
    active: %Schema{type: :boolean, description: "Whether product is active"},
    image: %Schema{type: :string, nullable: true, description: "Product image URL"},
    seller_id: %Schema{type: :integer},
    inserted_at: %Schema{type: :string, format: :"date-time"},
    updated_at: %Schema{type: :string, format: :"date-time"}
  }

  @product_schema %Schema{
    type: :object,
    properties: @product_properties
  }

  @product_response %Schema{
    type: :object,
    properties: %{data: @product_schema}
  }

  @products_response %Schema{
    type: :object,
    properties: %{data: %Schema{type: :array, items: @product_schema}}
  }

  @writable_fields [:title, :description, :price, :status, :location, :active, :image]
  @writable_properties Map.take(@product_properties, @writable_fields)

  @user_schema %Schema{
    type: :object,
    properties: %{
      id: %Schema{type: :integer},
      email: %Schema{type: :string},
      role: %Schema{type: :string},
      inserted_at: %Schema{type: :string, format: :"date-time"},
      updated_at: %Schema{type: :string, format: :"date-time"}
    }
  }

  @buyers_response %Schema{
    type: :object,
    properties: %{data: %Schema{type: :array, items: @user_schema}}
  }

  @error_schema %Schema{
    type: :object,
    properties: %{error: %Schema{type: :string}}
  }

  @validation_schema %Schema{
    type: :object,
    properties: %{
      error: %Schema{type: :string},
      details: %Schema{
        type: :object,
        additionalProperties: %Schema{
          type: :array,
          items: %Schema{type: :string}
        }
      }
    }
  }

  @security [%{"bearerAuth" => []}]
  @id_param [id: [in: :path, type: :integer, required: true, description: "Product ID"]]
  @unauthorized {"Authentication required", "application/json", @error_schema}
  @forbidden {"Insufficient permissions", "application/json", @error_schema}
  @not_found {"Product not found", "application/json", @error_schema}
  @invalid {"Validation failed", "application/json", @validation_schema}

  operation(:index,
    summary: "List products",
    description: "Get a list of all available products. Public endpoint.",
    tags: ["Products"],
    responses: [
      ok: {"Products list", "application/json", @products_response}
    ]
  )

  def index(conn, _params) do
    products = Catalog.list_products()
    json(conn, %{data: products})
  end

  operation(:show,
    summary: "Get product details",
    description: "Get detailed information about a specific product. Public endpoint.",
    tags: ["Products"],
    parameters: @id_param,
    responses: [
      ok: {"Product details", "application/json", @product_response},
      not_found: @not_found
    ]
  )

  def show(conn, %{"id" => id}) do
    product = Catalog.get_product!(id)
    json(conn, %{data: product})
  end

  operation(:create,
    summary: "Create product",
    description: "Create a new product. Requires seller or admin role.",
    tags: ["Products"],
    security: @security,
    request_body:
      {"Product data", "application/json",
       %Schema{
         type: :object,
         properties: @writable_properties,
         required: [:title, :description, :price, :status, :location, :active, :image]
       }},
    responses: [
      created: {"Product created", "application/json", @product_response},
      unauthorized: @unauthorized,
      forbidden: @forbidden,
      unprocessable_entity: @invalid
    ]
  )

  def create(conn, params) do
    user = conn.assigns[:current_user]

    with {:ok, user} <- require_auth(user),
         :ok <- require_seller(user) do
      attrs =
        params
        |> Map.take(["title", "description", "price", "status", "location", "active", "image"])
        |> Map.put("seller_id", user.id)

      case Catalog.create_product(attrs) do
        {:ok, %Product{} = product} ->
          conn
          |> put_status(:created)
          |> json(%{data: product})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{
            error: "validation_failed",
            details: changeset_errors(changeset)
          })
      end
    else
      {:error, status, message} ->
        conn
        |> put_status(status)
        |> json(%{error: message})
    end
  end

  operation(:update,
    summary: "Update product",
    description: "Update a product. Requires seller or admin role and ownership, unless admin.",
    tags: ["Products"],
    security: @security,
    parameters: @id_param,
    request_body:
      {"Product data", "application/json",
       %Schema{
         type: :object,
         properties: @writable_properties
       }},
    responses: [
      ok: {"Product updated", "application/json", @product_response},
      unauthorized: @unauthorized,
      forbidden: @forbidden,
      not_found: @not_found,
      unprocessable_entity: @invalid
    ]
  )

  def update(conn, %{"id" => id} = params) do
    user = conn.assigns[:current_user]

    with {:ok, user} <- require_auth(user),
         :ok <- require_seller(user),
         product <- Catalog.get_product!(id),
         :ok <- require_owner(user, product) do
      attrs = Map.take(params, ["title", "description", "price", "status", "location", "active", "image"])

      case Catalog.update_product(product, attrs) do
        {:ok, %Product{} = product} ->
          json(conn, %{data: product})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{
            error: "validation_failed",
            details: changeset_errors(changeset)
          })
      end
    else
      {:error, status, message} ->
        conn
        |> put_status(status)
        |> json(%{error: message})
    end
  end

  operation(:delete,
    summary: "Delete product",
    description: "Delete a product. Requires seller or admin role and ownership, unless admin.",
    tags: ["Products"],
    security: @security,
    parameters: @id_param,
    responses: [
      no_content: "Product deleted",
      unauthorized: @unauthorized,
      forbidden: @forbidden,
      not_found: @not_found
    ]
  )

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
        conn
        |> put_status(status)
        |> json(%{error: message})
    end
  end

  operation(:buyers,
    summary: "List product buyers",
    description:
      "List users who have this product in their basket. Requires seller or admin role and ownership, unless admin.",
    tags: ["Products"],
    security: @security,
    parameters: @id_param,
    responses: [
      ok: {"Buyers list", "application/json", @buyers_response},
      unauthorized: @unauthorized,
      forbidden: @forbidden,
      not_found: @not_found
    ]
  )

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
        conn
        |> put_status(status)
        |> json(%{error: message})
    end
  end

  # Helpers

  defp require_auth(nil), do: {:error, :unauthorized, "unauthorized"}
  defp require_auth(user), do: {:ok, user}

  defp require_seller(%{role: role}) when role in ["seller", "admin"], do: :ok
  defp require_seller(_), do: {:error, :forbidden, "seller_only"}

  defp require_owner(%{role: "admin"}, %Product{}), do: :ok

  defp require_owner(user, %Product{seller_id: seller_id}) do
    if user.id == seller_id do
      :ok
    else
      {:error, :forbidden, "not_owner"}
    end
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
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end