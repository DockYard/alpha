defmodule Server.HTML.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.
  """
  use Server.HTML, :layout

  # uncomment this like if you want to change to using external templates instead of inline
  # embed_templates "{app,root}.html"
  #
  # this would get extracted as root.html.heex
  def root(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en" class="[scrollbar-gutter:stable]">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={get_csrf_token()} />
        <.live_title suffix=" · Phoenix Framework">
          <%= assigns[:page_title] || "Server" %>
        </.live_title>
        <link phx-track-static rel="stylesheet" href={~p"/assets/app.css"} />
        <script defer phx-track-static type="text/javascript" src={~p"/assets/app.js"}>
        </script>
      </head>
      <body class="bg-white">
        {@inner_content}
      </body>
    </html>
    """
  end

  # this would get extracted as app.html.heex
  def app(assigns) do
    ~H"""
    <header class="px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between border-b border-zinc-100 py-3 text-sm">
        <div class="flex items-center gap-4">
          <a href="/">
            <img src={~p"/images/logo.svg"} width="36" />
          </a>
          <p class="bg-brand/5 text-brand rounded-full px-2 font-medium leading-6">
            v{Application.spec(:alpha, :vsn)}
          </p>
        </div>
        <div class="flex items-center gap-4 font-semibold leading-6 text-zinc-900">
          <a href="https://twitter.com/elixirphoenix" class="hover:text-zinc-700">
            @elixirphoenix
          </a>
          <a href="https://github.com/phoenixframework/phoenix" class="hover:text-zinc-700">
            GitHub
          </a>
          <a
            href="https://hexdocs.pm/phoenix/overview.html"
            class="rounded-lg bg-zinc-100 px-2 py-1 hover:bg-zinc-200/80"
          >
            Get Started <span aria-hidden="true">&rarr;</span>
          </a>
        </div>
      </div>
    </header>
    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl">
        <.flash_group flash={@flash} />
        {@inner_content}
      </div>
    </main>
    """
  end
end
