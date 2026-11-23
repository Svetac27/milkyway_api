defmodule MilkywayApiWeb.ApiSpecTest do
  use MilkywayApiWeb.ConnCase, async: true

  test "serves Swagger UI and the gender list specification", %{conn: conn} do
    html = conn |> get("/swaggerui") |> html_response(200)
    assert html =~ "/api/openapi"

    spec = build_conn() |> get("/api/openapi") |> json_response(200)
    assert spec["paths"]["/api/genders"]["get"]["summary"] == "List genders"
    assert spec["paths"]["/api/categories"]["get"]["summary"] == "List categories"
    assert spec["paths"]["/api/groups"]["get"]["summary"] == "List groups"
    assert spec["paths"]["/api/member_data"]["get"]["summary"] == "List member data"
    assert spec["paths"]["/api/members"]["get"]["security"] == [%{"bearerAuth" => []}]
    assert spec["components"]["securitySchemes"]["bearerAuth"]["scheme"] == "bearer"
    assert [%{"url" => "/"}] = spec["servers"]
  end
end
