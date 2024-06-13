defmodule Flarex do
  @moduledoc """
  Documentation for `Flarex`.

  A flash message clearing package for Phoenix.
  """
alias Flarex.ProcessStore

  @doc """
    Sends a msg `:clear_flash` to `pid` after `timeout`.
    Calling the function again with the same `pid` before the previous `timeout` has run out, will override the call.

    The message sent has to be handled in the module calling `Flarex.clear_after/2` with `handle_info/2`.

      ## Example

          MyApp.HomeLive

            def mount(_params, _session, socket) do

              {:ok, socket}
            end

            def handle_event("click", _params, socket) do
              Flarex.clear_after(self(), 5000)
              {:noreply, socket |> put_flash(:info, "You clicked!")}
            end

            def handle_info(:clear_flash, socket) do
                Flarex.clean_up_ref(self())
              {:noreply, socket |> clear_flash()}
            end
          end
  """
  def clear_after(pid, timeout) when is_pid(pid) and is_integer(timeout) do
    retrieved_ref = ProcessStore.get_ref(pid)
      case length(retrieved_ref) do
        0->
        ref = Process.send_after(pid, :clear_flash, timeout)
        ProcessStore.add_ref(pid, ref)
      _->
        ProcessStore.delete_ref(pid)
        Process.cancel_timer(hd(hd(retrieved_ref)))
        ref = Process.send_after(pid, :clear_flash, timeout)
        ProcessStore.add_ref(pid, ref)
      end
  end

  def clear_after(_pid, _timeout) do
    raise("Bad args")
  end
@doc """
    Useful after `put_flash/3` and `push_navigate/2` combo.
    Checks whether socket contains a map of flashes with `:error` and `:info` keys. If yes, it runs `Flarex.clear_after/2`.

      ## Example

          MyApp.AuthLive

            def mount(_params, session, socket) do
               if session["nickname"] != nil do
                  {:ok, socket |> assign(:nickname, session["nickname"])}
                else
                  {:ok, socket |> put_flash(:error, "You need to be authorized") |> push_navigate(socket, to: ~p"/")}
                end
            end
          end

          MyApp.HomeLive

            def mount(_params, _session, socket) do
                Flarex.clear_after_redirect(socket, self(), 5000)
              {:ok, socket}
            end

            def handle_info(:clear_flash, socket) do
                Flarex.clean_up_ref(self())
              {:noreply, socket |> clear_flash()}
            end
          end
  """
  def clear_after_redirect(socket, pid, timeout) when is_pid(pid) and is_integer(timeout) do
    if Map.has_key?(socket.assigns.flash, "error") || Map.has_key?(socket.assigns.flash, "info") do
      clear_after(pid, timeout)
    end
  end

  def clear_after_redirect(_socket, _pid, _timeout) do
    raise("Bad args")
  end
  @doc """
    Removes the `pid` from :ets table.

      ## Examples

          def handle_info(:clear_flash, socket) do
              Flarex.clean_up_ref(self())
            {:noreply, socket |> clear_flash()}
          end
  """
  def clean_up_ref(pid) do
    ProcessStore.delete_ref(pid)
  end
end
