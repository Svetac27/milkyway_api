defmodule MilkywayApiWeb.MembersController do
  use MilkywayApiWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias MilkywayApi.Accounts
  alias OpenApiSpex.Schema

  operation(:index,
    summary: "List members",
    security: [%{"bearerAuth" => []}],
    responses: [
      ok:
        {"Member list", "application/json",
         %Schema{
           type: :object,
           properties: %{
             data: %Schema{
               type: :array,
               items: %Schema{
                 type: :object,
                 properties: %{
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
               }
             }
           }
         }},
      unauthorized:
        {"Authentication required", "application/json",
         %Schema{
           type: :object,
           properties: %{error: %Schema{type: :string}}
         }}
    ]
  )

  operation(:show, false)

  def index(conn, _params) do
    json(conn, %{data: Accounts.list_members()})
  end
end
