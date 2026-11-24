defmodule MilkywayApiWeb.MemberDataController do
  use MilkywayApiWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias MilkywayApi.Accounts
  alias OpenApiSpex.Schema

  operation(:index,
    summary: "List member data",
    description: "Sorted by order ascending, with null values last and ties sorted by ID.",
    responses: [
      ok:
        {"Member data list", "application/json",
         %Schema{
           type: :object,
           properties: %{
             data: %Schema{
               type: :array,
               items: %Schema{
                 type: :object,
                 properties: %{
                   id: %Schema{type: :integer},
                   name: %Schema{type: :string, nullable: true},
                   key: %Schema{type: :string, nullable: true},
                   type: %Schema{type: :string, nullable: true},
                   hide: %Schema{type: :boolean},
                   order: %Schema{type: :integer, nullable: true},
                   inserted_at: %Schema{type: :string, format: :"date-time"},
                   updated_at: %Schema{type: :string, format: :"date-time"}
                 }
               }
             }
           }
         }}
    ]
  )

  operation(:show, false)

  def index(conn, _params) do
    json(conn, %{data: Accounts.list_member_data()})
  end
end
