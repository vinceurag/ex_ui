defmodule ExUi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      %{
        id: ExUi.Utils.Watcher,
        start:
          {ExUi.Utils.Watcher, :start_link,
           [[dirs: [File.cwd!() <> "/lib/ex_ui/input"], name: :file_watcher]]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExUi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
