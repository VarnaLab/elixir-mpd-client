defmodule ElixirMpdServer.MpdPing do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_args) do
    Process.send_after(__MODULE__, :ping, 1000)
    {:ok, nil}
  end

  def handle_info(:ping, state) do
    ElixirMpdServer.MpdServer.ping()
    Process.send_after(__MODULE__, :ping, 1000)

    {:noreply, state}
  end
end
