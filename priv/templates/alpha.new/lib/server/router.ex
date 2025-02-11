defmodule Server.Router do
  use Server, :router

  pipeline :client do
    plug :accepts, [
      "html",
      "swiftui"
    ]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout,
      html: {Server.HTML.Layouts, :root},
      swiftui: {Server.SwiftUI.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Server.Live do
    pipe_through :client

    live "/", Home
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:<%= @otp_app %>, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :client

      live_dashboard "/dashboard" #, metrics: Server.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
