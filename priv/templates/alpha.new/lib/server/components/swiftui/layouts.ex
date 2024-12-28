defmodule Server.SwiftUI.Layouts do
  use Server.SwiftUI, :layout

  # uncomment this like if you want to change to using external templates instead of inline
  # embed_templates "{app,root}.swiftui*"

  # this would get extracted as app.html.heex

  # this would get extracted as root.swiftui.heex
  # you can also implement templates for specific target: root.swiftui+watchos.neex
  def root(assigns, _interface) do
    ~LVN"""
    <csrf-token value={get_csrf_token()} />
    <Style url={~p"/assets/app.swiftui.styles"} />
    <NavigationStack>
      {@inner_content}
    </NavigationStack>
    """
  end

  # this would get extracted as app.swiftui.heex
  def app(assigns, _interface) do
    ~LVN"""
    <.flash_group flash={@flash} />
    {@inner_content}
    """
  end
end
