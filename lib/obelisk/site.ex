defmodule Obelisk.Site do

  def initialize do
    File.touch ".gitignore"
    create_default_theme
    create_content_dirs
    Obelisk.Post.create("Welcome to Obelisk")
    File.write './site.yml', Obelisk.Templates.config
    
    update_gitignore
  end

  def test_setup(dir) do
    File.cd(dir)
    initialize
  end

  def clean do
    File.rm_rf "./build"
    File.mkdir "./build"
  end

  def create_default_theme do
    File.mkdir "./themes"
    File.mkdir "./themes/default"
    create_assets_dirs
    create_layout_dirs
  end

  defp create_assets_dirs do
    File.mkdir "./themes/default/assets"
    File.mkdir "./themes/default/assets/css"
    File.mkdir "./themes/default/assets/js"
    File.mkdir "./themes/default/assets/img"
    File.write "./themes/default/assets/css/base.css", Obelisk.Templates.base_css
  end

  defp create_content_dirs do
    File.mkdir "./posts"
    File.mkdir "./drafts"
    File.mkdir "./pages"
  end

  defp create_layout_dirs do
    File.mkdir "./themes/default/layout"
    File.write "./themes/default/layout/post.eex", Obelisk.Templates.post_template
    File.write "./themes/default/layout/layout.eex", Obelisk.Templates.layout
    File.write "./themes/default/layout/index.eex", Obelisk.Templates.index
    File.write "./themes/default/layout/page.eex", Obelisk.Templates.page_template
  end

  @gitignore_patterns ~w[/build]
  defp current_gitignore_patterns do
    File.stream!(".gitignore")
    |> Enum.map(&String.trim/1)
  end
  
  defp update_gitignore do
    (@gitignore_patterns -- current_gitignore_patterns())
    |> Enum.into(File.stream!(".gitignore", [:append]))
  end

  defp find_in_gitignore(io_device, match) do
    line = IO.read(io_device, :line)

    if is_binary(line) do
      line = String.trim(line)
    end
    
    case 1 do
      _ when line == match -> true
      _ when is_tuple(line) -> false
      :eof -> false
      _ -> find_in_gitignore(io_device, match)
    end
  end
  
  defp append_gitignore(io_device, [head | tail]) do
    IO.write(io_device, "\n#{head}")

    if Enum.empty?(tail) do
      IO.write(io_device, "\n")
    else
      append_gitignore(io_device, tail)
    end
  end

end
