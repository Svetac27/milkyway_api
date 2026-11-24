defmodule MilkywayApiWeb.CategoriesController do
  use MilkywayApiWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias MilkywayApi.Accounts
  alias OpenApiSpex.Schema

  operation(:index,
    summary: "List categories",
    responses: [
      ok:
        {"Category list", "application/json",
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
    json(conn, %{data: Accounts.list_categories()})
  end
end
