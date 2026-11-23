defmodule MilkywayApiWeb.ApiSpecTest do
  use MilkywayApiWeb.ConnCase, async: true

  test "serves Swagger UI and the gender list specification", %{conn: conn} do
    html = conn |> get("/swaggerui") |> html_response(200)
    assert html =~ "/api/openapi"

    spec = build_conn() |> get("/api/openapi") |> json_response(200)
    assert spec["paths"]["/api/genders"]["get"]["summary"] == "List genders"
    assert [%{"url" => "/"}] = spec["servers"]
  end
end
