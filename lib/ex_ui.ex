defmodule ExUi do
  import XmlBuilder

  def generate_html(file_path) do
    try do
      {:ok, ast} =
        file_path
        |> File.read!()
        |> Code.string_to_quoted()

      elements = [process_stacks(ast)]

      html =
        document([
          doctype("html",
            public: [
              "-//W3C//DTD XHTML 1.0 Transitional//EN",
              "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
            ]
          ),
          element(:html, [element(:header, nil, nil), element(:body, nil, elements)])
        ])
        |> generate()

      File.write!("lib/ex_ui/output/" <> Path.basename(file_path, ".exui") <> ".html", html)
    rescue
      _ -> :error
    end
  end

  defp process_stacks({stack_type, _, [[do: {:__block__, _, stack}]]}) do
    element(:div, nil, process_stack(stack_type, stack))
  end

  defp process_stacks({_stack_type, _, [[do: _]]} = stack) do
    do_process_stack(stack)
  end

  defp process_stack(stack_type, components) do
    components
    |> Enum.reduce([], fn el, acc ->
      processed_component = do_process_stack(el)

      cond do
        stack_type == :vstack && !Enum.empty?(acc) ->
          [processed_component, element(:br, nil, nil) | acc]

        true ->
          [processed_component | acc]
      end
    end)
    |> Enum.reverse()
  end

  defp do_process_stack({stack_type, _, [[do: {:__block__, _, stack}]]}) do
    element(:div, nil, process_stack(stack_type, stack))
  end

  defp do_process_stack({_stack_type, _, [[do: stack]]}) do
    [{{type, _, [content | attrs]}, _} | stylings] = Macro.unpipe(stack)

    component = {type, content, List.flatten(attrs)}

    style = generate_style(stylings)

    build_component(component, style)
  end

  defp do_process_stack(els) do
    [{{type, _, [content | attrs]}, _} | stylings] = Macro.unpipe(els)

    component = {type, content, List.flatten(attrs)}

    style = generate_style(stylings)

    build_component(component, style)
  end

  defp generate_style(stylings) do
    Enum.reduce(stylings, "", fn s, acc ->
      "#{acc}#{build_style(s)}"
    end)
  end

  defp build_style({{:foreground_color, _, [color]}, _}) do
    "color:#{color};"
  end

  defp build_style({{:padding, _, [amount]}, _}) do
    "padding:#{amount}px;"
  end

  defp build_style({{:padding, _, [amount, unit]}, _}) do
    "padding:#{amount}#{unit};"
  end

  defp build_style({{:padding, _, _}, _}) do
    "padding:20px;"
  end

  defp build_style({{style, _, [value]}, _}) do
    style = String.replace(Atom.to_string(style), "_", "-")

    "#{style}:#{value};"
  end

  defp build_component({:text, content, _}, style) do
    element(:span, %{style: style}, content)
  end

  defp build_component({:image, content, _}, style) do
    element(:img, %{src: content, style: style}, nil)
  end

  defp build_component({:a, content, attrs}, style) do
    element(:a, %{href: attrs[:href], style: style}, content)
  end

  defp build_component({:link, content, attrs}, style) do
    element(:a, %{href: attrs[:href], style: style}, content)
  end

  defp build_component({tag, content, attrs}, style) do
    element(tag, Map.merge(%{style: style}, Map.new(attrs)), content)
  end
end
