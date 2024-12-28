defmodule Server.HTML do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use ServerWeb, :controller
      use ServerWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  import Server, only: [
    verified_routes: 0
  ]

  @doc ~S'''
  Set up a module as a LiveView Native format-specific render component

      defmodule Server.HTML.Home do
        use Server.HTML, :render_component

        def render(assigns, _interface) do
          ~LVN"""
          <Text>Hello, world!</Text>
          """
        end
      end
  '''
  def render_component do
    quote do
      use LiveViewNative.Component,
        format: :html,
        as: :render,
        root: "."

      unquote(helpers())
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(helpers())
    end
  end

  def layout do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers
      unquote(helpers())
    end
  end

  defp helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import Server.HTML.CoreComponents
      import Server.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

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
