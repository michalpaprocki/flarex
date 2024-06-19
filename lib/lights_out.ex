defmodule LightsOut do
  import Phoenix.LiveView.Utils, only: [put_flash: 3, clear_flash: 1]
  @moduledoc """
  Documentation for `LightsOut`.

  A flash message clearing package for Phoenix.
  """
alias LightsOut.ProcessStore

  @doc """
    Puts `key` and `message` into Phoenix.LiveView.Utils.put_flash/3 function.
    Sends a msg `:clear_flash` to `pid` after `timeout`.
    Calling the function again with the same `pid` before the previous `timeout` has run out, will override the call.

    The message sent has to be handled in the module calling `LightsOut.clear_after/2` with `handle_info/2`.

      ## Example

          MyApp.HomeLive

            def mount(_params, _session, socket) do

              {:ok, socket}
            end

            def handle_event("click", _params, socket) do
              LightsOut.clear_after(self(), 5000)
              {:noreply, socket |> put_flash(:info, "You clicked!")}
            end

            def handle_info(:clear_flash, socket) do
                LightsOut.clean_up_ref(self())
              {:noreply, socket |> clear_flash()}
            end
          end
  """
  def flash_and_clear_after(socket = %Phoenix.LiveView.Socket{}, key, message, pid, timeout) when is_pid(pid) and is_integer(timeout) and is_atom(key) do
    retrieved_ref = ProcessStore.get_ref(pid)
      case length(retrieved_ref) do
        0->
        ref = Process.send_after(pid, :clear_flash, timeout)
        ProcessStore.add_ref(pid, ref)
        socket |> put_flash(key, message)

      _->
        ProcessStore.delete_ref(pid)
        Process.cancel_timer(hd(hd(retrieved_ref)))
        ref = Process.send_after(pid, :clear_flash, timeout)
        ProcessStore.add_ref(pid, ref)
        socket |> put_flash(key, message)
      end
  end
  def flash_and_clear_after(_socket, _flash_type, _message,  _pid, _timeout) do
    raise("Bad args")
  end

  def clear_after(%Phoenix.LiveView.Socket{}, pid, timeout) when is_pid(pid) and is_integer(timeout) do
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

  def clear_after(_socket, _pid, _timeout) do
    raise("Bad args")
  end
@doc """
    Useful after `put_flash/3` and `push_navigate/2` combo.
    Checks whether socket contains a map of flashes with `:error` and `:info` keys. If yes, it runs `LightsOut.clear_after/2`.

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
                LightsOut.clear_after_redirect(socket, self(), 5000)
              {:ok, socket}
            end

            def handle_info(:clear_flash, socket) do
                LightsOut.clean_up_ref(self())
              {:noreply, socket |> clear_flash()}
            end
          end
  """
  def clear_after_redirect(socket= %Phoenix.LiveView.Socket{}, pid, timeout) when is_pid(pid) and is_integer(timeout) do
    if length(Map.to_list(socket.assigns.flash)) > 0 do
      clear_after(socket, pid, timeout)
    end
  end

  def clear_after_redirect(_socket, _pid, _timeout) do
    raise("Bad args")
  end
  @doc """
    Removes the `pid` from :ets table.

      ## Examples

          def handle_info(:clear_flash, socket) do
              LightsOut.clean_up_ref(self())
            {:noreply, socket |> clear_flash()}
          end
  """
  def clean_up_ref(pid) do
    ProcessStore.delete_ref(pid)
  end

end
