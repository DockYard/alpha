defmodule Mix.Tasks.Alpha.New do
  @moduledoc """
  Creates a new Alpha Stack project.

  """
  use Mix.Task

  @spinners "⠁⠂⠄⡀⡁⡂⡄⡅⡆⡇⡏⡗⡧⣇⣏⣗⣧⣯⣷⣿⢿⣻⢻⢽⣹⢹⢺⢼⣸⢸⠸⢘⠘⠨⢈⠈⠐⠠⢀ " |> String.split("")

  def run([name]) do
    generate_project(name)
  end

  def run(_argv) do
    raise "Missing app name"
  end

  defp generate_project(name) do
    otp_app = Macro.underscore(name)

    bindings = [
      name: name,
      otp_app: otp_app,
      secret_key_base_dev: random_string(64),
      secret_key_base_test: random_string(64),
      signing_salt: random_string(8),
      lv_signing_salt: random_string(8)
    ]

    from =
      :code.priv_dir(:alpha)
      |> List.to_string()
      |> Path.join("templates/alpha.new")

    to = otp_app

    templates =
      from
      |> Path.join("/**/*")
      |> Path.wildcard()
      |> Enum.reject(&File.dir?/1)
      |> Enum.map(fn(path) ->
        path
        |> String.split(from)
        |> List.last()
      end)

    templates = [".gitignore", ".vscode/settings.json" | templates]

    Enum.map(templates, &Path.dirname(&1))
    |> Enum.uniq()
    |> Enum.each(fn(path) ->
      File.mkdir_p(Path.join(to, path))
    end)

    templates
    |> Enum.each(fn(path) ->
      file = EEx.eval_file(Path.join(from, path), assigns: bindings)
      Mix.Generator.create_file(Path.join(to, path), file)
    end)

    File.cd!(otp_app, fn ->
      Mix.shell().info([:green, "* running ", :reset, "mix setup"])
      {:ok, task_pid} = Task.start(fn -> spinner({:wait, 0, 0}) end)
      send(task_pid, :start)
      Mix.Shell.cmd("mix setup", [], fn data ->
        data
        |> String.split(~r/(\r|\n)/, trim: true)
        |> Enum.each(fn(line) ->
          line = String.trim(line)
          send(task_pid, {:line_length, String.length(line)})
          IO.write("\r\e[2C\e[K\e[?7l#{String.trim(line)}")
          Process.sleep(2)
        end)
      end)
      IO.write("\r\e[K")
      send(task_pid, :stop)
    end)
  end

  defp spinner({stage, idx, line_length} = state) do
    receive do
      :start -> spinner({:start, idx, line_length})
      {:line_length, new_line_length} -> spinner({stage, idx, new_line_length})
      :stop -> :ok

    after
      0 ->
        Process.sleep(80)
        case state do
          {:start, idx, line_length} ->
            spinners_length = length(@spinners)
            spinner = Enum.at(@spinners, rem(idx, spinners_length))
            IO.write("\r#{spinner}\e[#{line_length + 3}G")

            spinner({:start, rem(idx + 1, spinners_length), line_length})
          state -> spinner(state)
        end
    end
  end

  defp random_string(length),
    do: :crypto.strong_rand_bytes(length) |> Base.encode64() |> binary_part(0, length)
end
