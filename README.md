# elixir-mpd-client
*WIP* MPD client made with Elixir

 For the application to work, it is currently required to have `mpd` installed and running as a daemon on the default port (`6600`).

# Installation
 1. Clone the repo;
 2. Go into the repo directory and issue `mix deps.get`;
 3. Issue `iex -S mix phx.server`;
 4. Play around with some of the currently implemented commands:
   - `ElixirMpdServer.MpdServer.next()`;
   - `ElixirMpdServer.MpdServer.previous()`;
   - `ElixirMpdServer.MpdServer.playlist_info()`;
   - `ElixirMpdServer.MpdServer.status()`.
 
