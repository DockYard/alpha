defmodule Server do
  @moduledoc """
  Server defines common functionality that is used within render components
  """


  # These modules are defined here to reduce the initial files being generated.
  # If you need to feel free to break them out into separate files
  defmodule Mailer do
    use Swoosh.Mailer, otp_app: :<%= @otp_app %>
  end

  defmodule Gettext do
    use Elixir.Gettext.Backend, otp_app: :<%= @otp_app %>
  end

  defmodule Repo do
    use Ecto.Repo,
      otp_app: :<%= @otp_app %>,
      adapter: Ecto.Adapters.Postgres
  end

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: Server.Endpoint,
        router: Server.Router,
        statics: Server.static_paths()
    end
  end

  def live_view do
    quote location: :keep do
      use Phoenix.LiveView
      use LiveViewNative.LiveView,
        formats: [:html, :swiftui],
        layouts: [
          html: {Server.HTML.Layouts, :app},
          swiftui: {Server.SwiftUI.Layouts, :app}
        ],
        dispatch_to: fn(module, format_suffix) ->
          name = Module.split(module) |> List.last()
          Module.concat([Server, format_suffix, name])
        end

      unquote(helpers())

      @impl true
      def render(var!(assigns)), do: ~H"<div>Hello</div>"
    end
  end

  defp helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import Server.Gettext

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
