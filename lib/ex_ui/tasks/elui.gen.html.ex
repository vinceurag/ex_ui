defmodule Mix.Tasks.ExUi.Gen.Html do
  @moduledoc "Generates an HTML file from an ExUI file."
  @shortdoc "Generates HTML"

  use Mix.Task

  @impl Mix.Task
  def run([path]) do
    unless File.exists?("lib/ex_ui/output"), do: File.mkdir!("lib/ex_ui/output")

    ExUi.generate_html(path)

    Mix.shell().info(
      "Success! lib/ex_ui/output/#{Path.basename(path, ".exui") <> ".html"} has been generated."
    )
  end
end
