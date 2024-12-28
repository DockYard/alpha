defmodule Server.HTML.Home do
  use Server.HTML, :render_component

  # you can delete this function and ise an external template
  # if you prefer: home.html.neex
  def render(assigns) do
    ~H"""
    <div>Hello, world!</div>
    """
  end
end
