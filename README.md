# MilkywayApi

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4400`](http://localhost:4400) from your browser.

## Run with Docker

Requirements: Docker with the Compose plugin.

1. Create a local environment file and generate a secret:

   ```bash
   cp .env.example .env
   mix phx.gen.secret
   ```

   Copy the generated value into `SECRET_KEY_BASE` in `.env`.

2. Build the image and start the app and PostgreSQL:

   ```bash
   docker compose up --build
   ```

   The app runs database migrations on startup. Visit [`localhost:4400`](http://localhost:4400).

3. Stop the containers with `Ctrl+C`, or run `docker compose down` in another terminal.
   The database data is kept in a Docker volume; to remove it too, run
   `docker compose down -v`.

The Compose setup is intended for local use. Change the PostgreSQL credentials and
use a separately generated secret before deploying anywhere accessible to others.

### Bootstrap the first admin

Public registration supports `buyer` and `seller` roles, but cannot grant `admin`.
Create a regular account, then promote it once through the local database:

```bash
docker compose exec db psql -U postgres -d milkyway_api_prod \
  -c "UPDATE users SET role = 'admin' WHERE email = 'admin@example.com';"
```

Replace the email with the account you registered. After promotion, log in at
`POST /api/login` and use the returned bearer token for admin-only user management.
Admins can also create other admins through `POST /api/users`.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## API quickstart (users)

Base URL: `http://localhost:4400/api`

- List users

  ```bash
  curl http://localhost:4400/api/users \
    -H "Authorization: Bearer ADMIN_TOKEN"
  ```

- Get user by id

  ```bash
  curl http://localhost:4400/api/users/1 \
    -H "Authorization: Bearer ADMIN_TOKEN"
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
    -H "Authorization: Bearer ADMIN_TOKEN" \
  	-d '{"email":"alice.new@example.com","password":"password123","role":"buyer"}'
  ```

- Delete user

  ```bash
  curl -X DELETE http://localhost:4400/api/users/1 \
    -H "Authorization: Bearer ADMIN_TOKEN"
  ```

Notes:

- Public registration can create `buyer` and `seller` accounts. Only admins can list,
  view, update, or delete users, or create another admin.
- Successful create returns `201` with user data.
- Successful delete returns `204` with empty body.
- Missing user returns `404` with `{ "error": "not_found" }`.
- Validation errors return `422` with `{ "error": "validation_failed", "details": ... }`.
- Obtain a token by logging in with `POST /api/login`; send it as
  `Authorization: Bearer YOUR_TOKEN` on admin-only requests.

## API quickstart (products)

Base URL: `http://localhost:4400/api`

Log in at `POST /api/login` and use the returned token on protected routes.

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
    -H "Authorization: Bearer SELLER_TOKEN" \
    -d '{"title":"MacBook Air","description":"M2 13-inch","price":1200,"status":"active","location":"Belgrade"}'
  ```

- Update product (seller owner only)

  ```bash
  curl -X PATCH http://localhost:4400/api/products/1 \
    -H "content-type: application/json" \
    -H "Authorization: Bearer SELLER_TOKEN" \
    -d '{"price":1100,"status":"reserved"}'
  ```

- Delete product (seller owner only)

  ```bash
  curl -X DELETE http://localhost:4400/api/products/1 \
    -H "Authorization: Bearer SELLER_TOKEN"
  ```

Notes:

- Admins can create products and update/delete products regardless of seller ownership.
- `GET /api/basket` returns all basket entries to admins, including each buyer ID.
  Admins can also delete any basket entry.
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

# 3) Log in as seller and copy the returned token
curl -X POST http://localhost:4400/api/login \
  -H "content-type: application/json" \
  -d '{"email":"seller.e2e@example.com","password":"password123"}'

# 4) Create product as seller (replace SELLER_TOKEN with the token from step 3)
curl -X POST http://localhost:4400/api/products \
  -H "content-type: application/json" \
  -H "Authorization: Bearer SELLER_TOKEN" \
  -d '{"title":"ThinkPad X1","description":"Gen 11","price":1500,"status":"active","location":"Novi Sad"}'

# 5) Reserve product as seller-owner (replace PRODUCT_ID)
curl -X PATCH http://localhost:4400/api/products/PRODUCT_ID \
  -H "content-type: application/json" \
  -H "Authorization: Bearer SELLER_TOKEN" \
  -d '{"status":"reserved"}'

# 6) Mark as sold
curl -X PATCH http://localhost:4400/api/products/PRODUCT_ID \
  -H "content-type: application/json" \
  -H "Authorization: Bearer SELLER_TOKEN" \
  -d '{"status":"sold"}'

# 7) Verify final product state
curl http://localhost:4400/api/products/PRODUCT_ID
```

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
