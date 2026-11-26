defmodule MilkywayApiWeb.MembersController do
  use MilkywayApiWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias MilkywayApi.Accounts
  alias OpenApiSpex.Schema

  @member_properties %{
    id: %Schema{type: :integer},
    active: %Schema{type: :boolean},
    avatar: %Schema{type: :string, nullable: true},
    name: %Schema{type: :string, nullable: true},
    middle_name: %Schema{type: :string, nullable: true},
    last_name: %Schema{type: :string, nullable: true},
    gender: %Schema{type: :string, nullable: true},
    email: %Schema{type: :string, nullable: true},
    phone: %Schema{type: :string, nullable: true},
    generation: %Schema{type: :string, nullable: true},
    birthdate: %Schema{type: :string, format: :date, nullable: true},
    category: %Schema{type: :string, nullable: true},
    group: %Schema{type: :string, nullable: true},
    jmbg: %Schema{type: :string, nullable: true},
    registration: %Schema{type: :string, format: :date, nullable: true},
    medical: %Schema{type: :string, format: :date, nullable: true},
    first_registration: %Schema{type: :string, format: :date, nullable: true},
    last_registration: %Schema{type: :string, format: :date, nullable: true},
    inserted_at: %Schema{type: :string, format: :"date-time"},
    updated_at: %Schema{type: :string, format: :"date-time"}
  }
  @member_schema %Schema{type: :object, properties: @member_properties}
  @member_response %Schema{type: :object, properties: %{data: @member_schema}}
  @writable_fields [
    :active,
    :avatar,
    :name,
    :middle_name,
    :last_name,
    :gender,
    :email,
    :phone,
    :generation,
    :birthdate,
    :category,
    :group,
    :jmbg,
    :registration,
    :medical,
    :first_registration,
    :last_registration
  ]
  @writable_properties @member_properties
                       |> Map.take(@writable_fields)
                       |> Map.update!(:name, &%{&1 | nullable: false})
                       |> Map.update!(
                         :active,
                         &%{&1 | nullable: true, description: "Null is treated as false."}
                       )
  @create_request %Schema{
    type: :object,
    properties: @writable_properties,
    required: [:name]
  }
  @update_request %Schema{type: :object, properties: @writable_properties}
  @error_schema %Schema{type: :object, properties: %{error: %Schema{type: :string}}}
  @validation_schema %Schema{
    type: :object,
    properties: %{
      error: %Schema{type: :string},
      details: %Schema{
        type: :object,
        additionalProperties: %Schema{type: :array, items: %Schema{type: :string}}
      }
    }
  }
  @security [%{"bearerAuth" => []}]
  @id_param [id: [in: :path, type: :integer, required: true, description: "Member ID"]]
  @unauthorized {"Authentication required", "application/json", @error_schema}
  @forbidden {"Admin access required", "application/json", @error_schema}
  @not_found {"Member not found", "application/json", @error_schema}
  @invalid {"Validation failed", "application/json", @validation_schema}

  operation(:index,
    summary: "List members",
    security: @security,
    responses: [
      ok:
        {"Member list", "application/json",
         %Schema{
           type: :object,
           properties: %{
             data: %Schema{
               type: :array,
               items: @member_schema
             }
           }
         }},
      unauthorized: @unauthorized
    ]
  )

  operation(:show,
    summary: "Get a member",
    security: @security,
    parameters: @id_param,
    responses: [
      ok: {"Member", "application/json", @member_response},
      unauthorized: @unauthorized,
      not_found: @not_found
    ]
  )

  operation(:create,
    summary: "Create a member (admin only)",
    description: "Only name is required; active defaults to false and null is treated as false.",
    security: @security,
    request_body: {"Member fields", "application/json", @create_request},
    responses: [
      created: {"Member created", "application/json", @member_response},
      unauthorized: @unauthorized,
      forbidden: @forbidden,
      unprocessable_entity: @invalid
    ]
  )

  operation(:update,
    summary: "Update member fields (admin only)",
    description:
      "Only submitted fields are changed. Name cannot be blank or null; null active is treated as false.",
    security: @security,
    parameters: @id_param,
    request_body: {"Member fields to update", "application/json", @update_request},
    responses: [
      ok: {"Member updated", "application/json", @member_response},
      unauthorized: @unauthorized,
      forbidden: @forbidden,
      not_found: @not_found,
      unprocessable_entity: @invalid
    ]
  )

  operation(:delete,
    summary: "Permanently delete a member (admin only)",
    security: @security,
    parameters: @id_param,
    responses: [
      no_content: "Member deleted",
      unauthorized: @unauthorized,
      forbidden: @forbidden,
      not_found: @not_found,
      unprocessable_entity: @invalid
    ]
  )

  def index(conn, _params) do
    json(conn, %{data: Accounts.list_members()})
  end

  def show(conn, %{"id" => id}) do
    case Accounts.get_member(id) do
      nil -> error_response(conn, :not_found, "not_found")
      member -> json(conn, %{data: member})
    end
  end

  def create(conn, _params) do
    with :ok <- require_admin(conn) do
      case Accounts.create_member(conn.body_params) do
        {:ok, member} -> conn |> put_status(:created) |> json(%{data: member})
        {:error, changeset} -> validation_error(conn, changeset)
      end
    else
      {:error, status, message} -> error_response(conn, status, message)
    end
  end

  def update(conn, %{"id" => id}) do
    with :ok <- require_admin(conn),
         member when not is_nil(member) <- Accounts.get_member(id) do
      case Accounts.update_member(member, conn.body_params) do
        {:ok, member} -> json(conn, %{data: member})
        {:error, changeset} -> validation_error(conn, changeset)
      end
    else
      nil -> error_response(conn, :not_found, "not_found")
      {:error, status, message} -> error_response(conn, status, message)
    end
  end

  def delete(conn, %{"id" => id}) do
    with :ok <- require_admin(conn),
         member when not is_nil(member) <- Accounts.get_member(id) do
      case Accounts.delete_member(member) do
        {:ok, _member} -> send_resp(conn, :no_content, "")
        {:error, changeset} -> validation_error(conn, changeset)
      end
    else
      nil -> error_response(conn, :not_found, "not_found")
      {:error, status, message} -> error_response(conn, status, message)
    end
  end

  defp require_admin(%{assigns: %{current_user: %{role: "admin"}}}), do: :ok
  defp require_admin(_conn), do: {:error, :forbidden, "admin_only"}

  defp error_response(conn, status, message) do
    conn |> put_status(status) |> json(%{error: message})
  end

  defp validation_error(conn, changeset) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
        Enum.reduce(opts, message, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "validation_failed", details: errors})
  end
end
