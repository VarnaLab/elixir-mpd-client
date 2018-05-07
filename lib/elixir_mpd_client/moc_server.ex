defmodule MocServer do
  @moduledoc """
  This is holding the Moc server funcs
  """

  use GenServer

  @mocp "mocp"
  @moc_start "-p"
  @moc_stop "-x"
  @moc_pause "-P"
  @moc_unpause "-U"

  def start_link() do
    status = %{is_running: false,
               is_playing: false,
               dir: "",
               playlist: []}

    GenServer.start_link(__MODULE__, status, name: __MODULE__)
  end

  def start_link([dir]) do
    status = %{is_running: false,
               is_playing: false,
               dir: dir,
               playlist: []}

    GenServer.start_link(__MODULE__, status, name: __MODULE__)
  end

  def init(%{is_running: false, dir: dir} = state) do
    start_player(state)
    {:ok, %{state | is_running: true}}
  end

  def init(%{dir: dir} = state) do
    {:ok, state}
  end

  def start_player(%{is_running: false, dir: dir}) do
    GenServer.call(__MODULE__, {:start_player, dir})
  end
  def start_player(%{is_running: true}), do: IO.puts("Player is already running")

  def stop_player(%{is_running: true}) do
    GenServer.call(__MODULE__, {:stop_player})
  end
  def stop_player(%{is_running: false}), do: IO.puts("Player is not started yet")

  def play(%{is_playing: false}) do
    GenServer.call(__MODULE__, {:play})
  end
  def play, do: IO.puts("The song is already playing.")

  def pause(%{is_playing: true}) do
    GenServer.call(__MODULE__, {:pause})
  end
  def pause, do: IO.puts("The song is not playing yet.")

  ## GenServer calls

  def handle_call({:start_player, dir}, _from, state) do
    if dir != "" do
      @mocp
      |> Kernel.<>("-S")
      |> Kernek.<>(dir)
      |> String.to_charlist()
      |> :os.cmd()

      playlist = list_playlist(dir)
      IO.puts("Current playlist: #{inspect(playlist)}")

      {:noreply, :player_running, %{state | playlist: playlist}}
    else
      {:noreply, :player_running, state}
    end
  end

  def handle_call({:stop_player}, _from, state) do
    @mocp
    |> Kernel.<>("-x")
    |> String.to_charlist()
    |> :os.cmd()

    {:noreply, :player_stoped, %{state | is_running: false}}
  end

  def handle_call({:play}, _from, state) do
    @mocp
    |> Kernel.<>("-p")
    |> String.to_charlist()
    |> :os.cmd()

    {:noreply, :playing, %{state | is_playing: true}}
  end

  def handle_call({:pause}, _from, state) do
    @mocp
    |> Kernel.<>("-P")
    |> String.to_charlist()
    |> :os.cmd()

    {:noreply, :paused, %{state | is_playing: false}}
  end

  defp list_playlist(dir) do
    "ls -p "
    |> Kernel.<>(dir)
    |> Kernel.<>(" | grep -v /")
    |> String.to_charlist()
    |> :os.cmd()
    |> Kernel.to_string()
    |> String.split("\n")
    |> Enum.drop(-1)
  end
end
