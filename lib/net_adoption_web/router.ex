defmodule NetAdoptionWeb.Router do
  use NetAdoptionWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {NetAdoptionWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :detect_htmx_request
    plug :htmx_layout
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NetAdoptionWeb do
    pipe_through :browser

    get "/",              PageController, :home
    get "/check",         PageController, :check
    get "/check/:domain", PageController, :check
  end

  # These functions detect an HTMX request and set the proper assigns for
  # future use
  def detect_htmx_request(conn, _opts) do
    if get_req_header(conn, "hx-request") == ["true"] do
      assign(conn, :htmx, %{
        request: true,
        boosted: get_req_header(conn, "hx-boosted") != [],
        current_url: List.first(get_req_header(conn, "hx-current-url")),
        history_restore_request: get_req_header(conn, "hx-history-restore-request") == ["true"],
        prompt: List.first(get_req_header(conn, "hx-prompt")),
        target: List.first(get_req_header(conn, "hx-target")),
        trigger_name: List.first(get_req_header(conn, "hx-trigger-name")),
        trigger: List.first(get_req_header(conn, "hx-trigger"))
      })
    else
      conn
    end
  end
  def htmx_layout(conn, _opts) do
    if get_in(conn.assigns, [:htmx, :request]) do
      conn = put_root_layout(conn, html: false)

      if conn.assigns.htmx[:boosted] or conn.assigns.htmx[:history_restore_request] do
        put_layout(conn, html: {NetAdoptionWeb.Layouts, :app})
      else
        put_layout(conn, html: false)
      end
    else
      conn
      |> put_root_layout(html: {NetAdoptionWeb.Layouts, :root})
      |> put_layout(html: {NetAdoptionWeb.Layouts, :app})
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", NetAdoptionWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:net_adoption, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: NetAdoptionWeb.Telemetry
    end
  end
end
