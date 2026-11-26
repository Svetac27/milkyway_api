defmodule MilkywayApiWeb.ApiSpecTest do
  use MilkywayApiWeb.ConnCase, async: true

  test "serves Swagger UI and the gender list specification", %{conn: conn} do
    html = conn |> get("/swaggerui") |> html_response(200)
    assert html =~ "/api/openapi"

    spec = build_conn() |> get("/api/openapi") |> json_response(200)
    assert spec["paths"]["/api/genders"]["get"]["summary"] == "List genders"
    assert spec["paths"]["/api/categories"]["get"]["summary"] == "List categories"
    assert spec["paths"]["/api/groups"]["get"]["summary"] == "List groups"

    for path <- ["/api/categories", "/api/genders", "/api/groups"] do
      assert %{"type" => "string", "nullable" => true} =
               get_in(spec, [
                 "paths",
                 path,
                 "get",
                 "responses",
                 "200",
                 "content",
                 "application/json",
                 "schema",
                 "properties",
                 "data",
                 "items",
                 "properties",
                 "key"
               ])
    end

    assert spec["paths"]["/api/member_data"]["get"]["summary"] == "List member data"
    assert spec["paths"]["/api/members"]["get"]["security"] == [%{"bearerAuth" => []}]
    assert spec["paths"]["/api/members"]["post"]["security"] == [%{"bearerAuth" => []}]

    assert get_in(spec, [
             "paths",
             "/api/members",
             "post",
             "requestBody",
             "content",
             "application/json",
             "schema",
             "required"
           ]) == ["name"]

    for {path, method} <- [{"/api/members", "post"}, {"/api/members/{id}", "put"}] do
      properties =
        get_in(spec, [
          "paths",
          path,
          method,
          "requestBody",
          "content",
          "application/json",
          "schema",
          "properties"
        ])

      assert %{"type" => "string", "nullable" => false} = properties["name"]
      assert %{"type" => "boolean", "nullable" => true} = properties["active"]
      assert %{"type" => "string", "nullable" => true} = properties["avatar"]
      assert %{"type" => "string", "nullable" => true} = properties["medical"]
    end

    for method <- ["get", "put", "delete"] do
      assert spec["paths"]["/api/members/{id}"][method]["security"] == [%{"bearerAuth" => []}]
    end

    assert %{"type" => "string", "nullable" => true} =
             get_in(spec, [
               "paths",
               "/api/members",
               "get",
               "responses",
               "200",
               "content",
               "application/json",
               "schema",
               "properties",
               "data",
               "items",
               "properties",
               "avatar"
             ])

    assert spec["components"]["securitySchemes"]["bearerAuth"]["scheme"] == "bearer"
    assert [%{"url" => "/"}] = spec["servers"]
  end
end
