
defmodule TodoAppFullWeb.ErrorLive do
  use TodoAppFullWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Oops! Something went wrong.</h1>

    </div>
    """
  end
end
