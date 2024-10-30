defmodule WalletApiPariyWeb.Router do
  use WalletApiPariyWeb, :router
  import Plug.BasicAuth

  @username Application.compile_env(:wallet_api_pariy, :basic_auth)[:username]
  @password Application.compile_env(:wallet_api_pariy, :basic_auth)[:password]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {WalletApiPariyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :basic_auth, username: @username, password: @password
  end

  scope "/", WalletApiPariyWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  scope "/user", WalletApiPariyWeb do
    pipe_through :api

    post "/balance", UserController, :show_balance
  end

  scope "/transaction", WalletApiPariyWeb do
    pipe_through :api

    post "/bet", TransactionController, :create_bet
    post "/win", TransactionController, :create_win
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:wallet_api_pariy, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: WalletApiPariyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
