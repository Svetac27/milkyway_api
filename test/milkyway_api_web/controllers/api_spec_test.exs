defmodule MilkywayApiWeb.ApiSpecTest do
  use MilkywayApiWeb.ConnCase, async: true

  test "serves Swagger UI and the gender list specification", %{conn: conn} do
    html = conn |> get("/swaggerui") |> html_response(200)
    assert html =~ "/api/openapi"

    spec = build_conn() |> get("/api/openapi") |> json_response(200)
    assert spec["paths"]["/api/genders"]["get"]["summary"] == "List genders"
    assert spec["paths"]["/api/categories"]["get"]["summary"] == "List categories"
    assert spec["paths"]["/api/groups"]["get"]["summary"] == "List groups"
    assert spec["paths"]["/api/products"]["get"]["summary"] == "List products"
    assert spec["paths"]["/api/products/{id}/buyers"]["get"]["summary"] == "List product buyers"

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

    # Product endpoints validation
    assert spec["paths"]["/api/products"]["get"]["summary"] == "List products"
    assert spec["paths"]["/api/products"]["post"]["summary"] == "Create product"
    assert spec["paths"]["/api/products/{id}"]["get"]["summary"] == "Get product details"
    assert spec["paths"]["/api/products/{id}"]["patch"]["summary"] == "Update product"
    assert spec["paths"]["/api/products/{id}"]["delete"]["summary"] == "Delete product"
    assert spec["paths"]["/api/products/{id}/buyers"]["get"]["summary"] == "List product buyers"

    # Product endpoints require authentication for write operations
    assert spec["paths"]["/api/products"]["post"]["security"] == [%{"bearerAuth" => []}]
    assert spec["paths"]["/api/products/{id}"]["patch"]["security"] == [%{"bearerAuth" => []}]
    assert spec["paths"]["/api/products/{id}"]["delete"]["security"] == [%{"bearerAuth" => []}]
    assert spec["paths"]["/api/products/{id}/buyers"]["security"] == [%{"bearerAuth" => []}]

    # Product POST request body validation
    assert get_in(spec, [
             "paths",
             "/api/products",
             "post",
             "requestBody",
             "content",
             "application/json",
             "schema",
             "required"
           ]) == ["title", "description", "price", "status", "location"]

    # Product properties validation
    for method <- ["post", "patch"] do
      properties =
        get_in(spec, [
          "paths",
          "/api/products",
          method,
          "requestBody",
          "content",
          "application/json",
          "schema",
          "properties"
        ])

      assert %{"type" => "string"} = properties["title"]
      assert %{"type" => "string"} = properties["description"]
      assert %{"type" => "integer"} = properties["price"]
      assert %{"type" => "string"} = properties["status"]
      assert %{"type" => "string"} = properties["location"]
      assert %{"type" => "boolean"} = properties["active"]
      assert %{"type" => "string", "nullable" => true} = properties["image"]
    end

    # Product GET response schema
    assert %{"type" => "integer"} =
             get_in(spec, [
               "paths",
               "/api/products",
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
               "id"
             ])

    assert %{"type" => "string"} =
             get_in(spec, [
               "paths",
               "/api/products",
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
               "title"
             ])

    assert %{"type" => "boolean"} =
             get_in(spec, [
               "paths",
               "/api/products",
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
               "active"
             ])

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
