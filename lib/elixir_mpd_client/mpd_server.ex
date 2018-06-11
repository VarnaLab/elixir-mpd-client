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

  def play() do
    GenServer.cast(__MODULE__, :play)
  end

  def pause() do
    GenServer.cast(__MODULE__, :pause)
  end

  def playlist_info() do
    GenServer.call(__MODULE__, :playlist_info)
  end

  def ping() do
    GenServer.cast(__MODULE__, :ping)
  end

  def init(args) do
    {:ok, socket} =
      :gen_tcp.connect(
        {127, 0, 0, 1},
        6600,
        [:binary, active: false, keepalive: true, reuseaddr: true],
        :infinity
      )

    {:ok, "OK MPD 0.20.0\n"} = :gen_tcp.recv(socket, 0)
    {:ok, socket}
  end

  def handle_call(:status, _from, socket) do
    answer = receive_message(socket, commands_to_mpd(["status"]))

    {:reply, answer, socket}
  end

  def handle_call(:playlist_info, _from, socket) do
    answer = receive_message(socket, commands_to_mpd(["playlistinfo"]))

    {:reply, answer, socket}
  end

  def handle_cast(:next, socket) do
    "OK\n" = receive_message(socket, commands_to_mpd(["next"]))

    {:noreply, socket}
  end

  def handle_cast(:previous, socket) do
    "OK\n" = receive_message(socket, commands_to_mpd(["previous"]))

    {:noreply, socket}
  end

  def handle_cast(:play, socket) do
    "OK\n" = receive_message(socket, commands_to_mpd(["play 1"]))

    {:noreply, socket}
  end

  def handle_cast(:pause, socket) do
    "OK\n" = receive_message(socket, commands_to_mpd(["play 0"]))

    {:noreply, socket}
  end

  def handle_cast(:ping, socket) do
    "OK\n" = receive_message(socket, commands_to_mpd(["ping"]))

    {:noreply, socket}
  end

  defp commands_to_mpd(commands) do
    commands = Enum.join(commands, "\n")
    "command_list_begin\n#{commands}\ncommand_list_end\n"
  end

  defp receive_message(socket, command) do
    :ok = :gen_tcp.send(socket, command)
    {:ok, answer} = :gen_tcp.recv(socket, 0)

    answer
  end
end
