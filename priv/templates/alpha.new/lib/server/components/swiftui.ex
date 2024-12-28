defmodule Server.SwiftUI do
  @moduledoc """
  The entrypoint for defining your native interfaces, such
  as components, render components, layouts, and live views.

  This can be used in your application as:

      use MyAppNative, :live_view

  The definitions below will be executed for every
  component, so keep them short and clean, focused
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

      defmodule MyAppWeb.HomeLive.SwiftUI do
        use MyAppNative, [:render_component, format: :swiftui]

        def render(assigns, _interface) do
          ~LVN"""
          <Text>Hello, world!</Text>
          """
        end
      end
  '''
  def render_component do
    quote location: :keep do
      use LiveViewNative.Component,
        format: :swiftui,
        as: :render,
        root: "."

      unquote(helpers())
    end
  end

  @doc ~S'''
  Set up a module as a LiveView Native Component

      defmodule MyAppWeb.Components.CustomSwiftUI do
        use MyAppNative, [:component, format: :swiftui]

        attr :msg, :string, :required
        def home_textk(assigns) do
          ~LVN"""
          <Text>@msg</Text>
          """
        end
      end

  LiveView Native Components are identical to Phoenix Components. Please
  refer to the `Phoenix.Component` documentation for more information.
  '''
  def component(opts \\ []) do
    opts =
      opts
      |> Keyword.take([:root, :as])
      |> Keyword.put(:format, :swiftui)

    quote location: :keep do
      use LiveViewNative.Component, unquote(opts)

      unquote(helpers())
    end
  end

  @doc ~S'''
  Set up a module as a LiveView Natve Layout Component

      defmodule MyAppWeb.Layouts.SwiftUI do
        use MyAppNative, [:layout, format: :swiftui]

        embed_templates "layouts_swiftui/*"
      end
  '''
  def layout do
    quote location: :keep do
      use LiveViewNative.Component, format: :swiftui

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      def render(name, assigns) do
        function_name = Path.rootname(name) |> String.to_atom()
        interface = Map.get(assigns, :_interface, %{})
        apply(__MODULE__, function_name, [assigns, interface])
      end

      unquote(helpers())
    end
  end

  defp helpers do
    plugin = LiveViewNative.fetch_plugin!(:swiftui)

    imports = import_if_compiled([
      plugin.component,
      LiveViewNative.LiveForm.Component,
      Server.SwiftUI.CoreComponents
    ])

    quote location: :keep do
      import Server.Gettext
      unquote(imports)
      unquote(verified_routes())
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__([which | opts]) when is_atom(which) do
    apply(__MODULE__, which, [opts])
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defp import_if_compiled(modules) when is_list(modules) do
    Enum.reduce(modules, [], fn(module, acc) ->
      case Code.ensure_compiled(module) do
        {:error, _} -> acc
        {:module, _} -> [(quote do: import unquote(module)) | acc]
      end
    end)
    |> Enum.reverse()
  end
end
