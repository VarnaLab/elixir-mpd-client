defmodule ElixirMpdServer.MpdServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def status() do
    GenServer.call(__MODULE__, :status)
  end

  def next() do
    GenServer.cast(__MODULE__, :next)
  end

  def previous() do
    GenServer.cast(__MODULE__, :previous)
  end

  def playlist_info() do
    GenServer.call(__MODULE__, :playlist_info)
  end

  def init(args) do
    {:ok, socket} = :gen_tcp.connect({127, 0, 0, 1}, 6600, [:binary, active: false, keepalive: true], :infinity)
    {:ok, "OK MPD 0.20.0\n"} = :gen_tcp.recv(socket, 0)
    {:ok, socket}
  end

  def handle_call(:status, _from, socket) do
    :ok = :gen_tcp.send(socket, commands_to_mpd(["status"]))
    {:ok, answer} = :gen_tcp.recv(socket, 0)

    {:reply, answer, socket}
  end

  def handle_call(:playlist_info, _from, socket) do
    :ok = :gen_tcp.send(socket, commands_to_mpd(["playlistinfo"]))
    {:ok, answer} = :gen_tcp.recv(socket, 0)

    {:reply, answer, socket}
  end

  def handle_cast(:next, socket) do
    :ok = :gen_tcp.send(socket, commands_to_mpd(["next"]))
    {:ok, "OK\n"} = :gen_tcp.recv(socket, 0)

    {:noreply, socket}
  end

  def handle_cast(:previous, socket) do
    :ok = :gen_tcp.send(socket, commands_to_mpd(["previous"]))
    {:ok, "OK\n"} = :gen_tcp.recv(socket, 0)

    {:noreply, socket}
  end

  defp commands_to_mpd(commands) do
    commands = Enum.join(commands, "\n")
    "command_list_begin\n#{commands}\ncommand_list_end\n"
  end
end
