defmodule ExUi.Utils.Watcher do
  use GenServer

  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(args)

    dirs_list = args[:dirs]

    FileSystem.subscribe(watcher_pid)
    Logger.info("Watching #{List.first(dirs_list)}...")
    {:ok, %{watcher_pid: watcher_pid}}
  end

  def handle_info(
        {:file_event, watcher_pid, {path, _events}},
        %{watcher_pid: watcher_pid} = state
      ) do
    # Your own logic for path and events
    case ExUi.generate_html(path) do
      :error ->
        nil

      _ ->
        Logger.info(
          "Generated html file for lib/ex_ui/output/#{Path.basename(path, ".exui") <> ".html"}"
        )
    end

    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    # Your own logic when monitor stop
    Logger.info("Stopped watching files...")
    {:noreply, state}
  end
end
