# MilkywayApi

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4400`](http://localhost:4400) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## API quickstart (users)

Base URL: `http://localhost:4400/api`

- List users

  ```bash
  curl http://localhost:4400/api/users
  ```

- Get user by id

  ```bash
  curl http://localhost:4400/api/users/1
  ```

- Create user

  ```bash
  curl -X POST http://localhost:4400/api/users \
  	-H "content-type: application/json" \
  	-d '{"email":"alice@example.com","password":"password123","role":"seller"}'
  ```

- Update user

  ```bash
  curl -X PATCH http://localhost:4400/api/users/1 \
  	-H "content-type: application/json" \
  	-d '{"email":"alice.new@example.com","password":"password123","role":"buyer"}'
  ```

- Delete user

  ```bash
  curl -X DELETE http://localhost:4400/api/users/1
  ```

Notes:

- Successful create returns `201` with user data.
- Successful delete returns `204` with empty body.
- Missing user returns `404` with `{ "error": "not_found" }`.
- Validation errors return `422` with `{ "error": "validation_failed", "details": ... }`.

## API quickstart (products)

Base URL: `http://localhost:4400/api`

- List products (public)

  ```bash
  curl http://localhost:4400/api/products
  ```

- Get product by id (public)

  ```bash
  curl http://localhost:4400/api/products/1
  ```

- Create product (seller only)

  ```bash
  curl -X POST http://localhost:4400/api/products \
    -H "content-type: application/json" \
    -H "x-user-id: 1" \
    -d '{"title":"MacBook Air","description":"M2 13-inch","price":1200,"status":"active","location":"Belgrade"}'
  ```

- Update product (seller owner only)

  ```bash
  curl -X PATCH http://localhost:4400/api/products/1 \
    -H "content-type: application/json" \
    -H "x-user-id: 1" \
    -d '{"price":1100,"status":"reserved"}'
  ```

- Delete product (seller owner only)

  ```bash
  curl -X DELETE http://localhost:4400/api/products/1 \
    -H "x-user-id: 1"
  ```

Notes:

- Allowed product `status` values: `active`, `reserved`, `sold`, `hidden`.
- Missing or invalid auth for protected routes returns `401`.
- Non-seller user returns `403` with `seller_only`.
- Non-owner seller returns `403` with `not_owner`.
- Validation errors return `422` with `{ "error": "validation_failed", "details": ... }`.

### End-to-end test flow (copy/paste)

```bash
# 1) Create seller
curl -X POST http://localhost:4400/api/users \
  -H "content-type: application/json" \
  -d '{"email":"seller.e2e@example.com","password":"password123","role":"seller"}'

# 2) Create buyer
curl -X POST http://localhost:4400/api/users \
  -H "content-type: application/json" \
  -d '{"email":"buyer.e2e@example.com","password":"password123","role":"buyer"}'

# 3) Create product as seller (replace SELLER_ID with the id from step 1)
curl -X POST http://localhost:4400/api/products \
  -H "content-type: application/json" \
  -H "x-user-id: SELLER_ID" \
  -d '{"title":"ThinkPad X1","description":"Gen 11","price":1500,"status":"active","location":"Novi Sad"}'

# 4) Reserve product as seller-owner (replace PRODUCT_ID)
curl -X PATCH http://localhost:4400/api/products/PRODUCT_ID \
  -H "content-type: application/json" \
  -H "x-user-id: SELLER_ID" \
  -d '{"status":"reserved"}'

# 5) Mark as sold
curl -X PATCH http://localhost:4400/api/products/PRODUCT_ID \
  -H "content-type: application/json" \
  -H "x-user-id: SELLER_ID" \
  -d '{"status":"sold"}'

# 6) Verify final product state
curl http://localhost:4400/api/products/PRODUCT_ID
```

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
