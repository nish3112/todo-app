defmodule TodoAppFullWeb.Router do
  use TodoAppFullWeb, :router
  import TodoAppFullWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TodoAppFullWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TodoAppFullWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/", PageController, :home

    live "/todos", TodoLive.Index, :index
    live "/todos/new", TodoLive.Index, :new
    live "/todos/:id/edit", TodoLive.Index, :edit

    live "/todos/:id", TodoLive.Show, :show
    # live "/todos/:id/show/edit", TodoLive.Show, :edit

    # New paths

    live "/todos/:id/show/new", TodoLive.Show, :new
    live "/todos/:id/edit/:task_id", TodoLive.Show, :sub_edit
    live "/todos/:id/permissions", TodoLive.Show, :permissions

    live "/error", ErrorLive, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", TodoAppFullWeb do
    pipe_through :browser
    get "/register", ApiController, :api_register
  end

  scope "/api", TodoAppFullWeb do
    pipe_through :api

    get "/example", ApiController, :index

  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:todo_app_full, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TodoAppFullWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", TodoAppFullWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{TodoAppFullWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", TodoAppFullWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TodoAppFullWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", TodoAppFullWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{TodoAppFullWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
