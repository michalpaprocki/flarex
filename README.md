# LiveViewFlashCleaner 🧹

Simple genserver wrapper of an :ets table, that keeps track of started references spawned by the Process.send_after/4 fn.


![example_flash_cleaner](https://github.com/michalpaprocki/live_view_flash_cleaner/blob/main/img/example_flash_cleaner.gif)



## Motivation

Phoenix flash messages are great, you can use them out of the box. Additionally nothing stops you from customizing them to your liking in core_components file. The only thing I found lacking, is some kind of a mechanism that will auto-clear the message after a timeout.

## How it works:

Since Phoenix LiveViews are [elixir processes](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#content), we can use [Process.send_after/3](https://hexdocs.pm/elixir/Process.html#send_after/3) to call themselves, and then use [handle_info/2](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#c:handle_info/2) callback to clear the flash messages with [clear_flash/1](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#clear_flash/1) or [clear_flash/2](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#clear_flash/2). Since the call will always execute after the time specified in send.after/3, sending many messages within a short span of time, may lead to a situation, where clear_flash/1 will be called in an interval-like fashion. That's a behaviour we don't want, therefore, LiveViewFlashCleaner.flash_and_clear_after/5 takes LiveView's pid and stores it along with send_after/3 reference in an :ets table. When another flash message will be send, before the timeout specified in flash_and_clear_after/5, LiveViewFlashCleaner will look up the provided pid in the :ets table and, if it finds a record with stored reference, cancel the queued send_after/3 with [Process.cancel_timer/1](https://hexdocs.pm/elixir/Process.html#cancel_timer/1).


```elixir
  MyApp.HomeLive
    import LiveViewFlashCleaner
      def mount(_params, _session, socket) do

        {:ok, socket}
      end

      def handle_event("click", _params, socket) do

        {:noreply, socket |> flash_and_clear_after(:info, "You clicked!", self(), 5000)}
      end

      def handle_info(:clear_flash, socket) do

        clean_up_ref(self())
        {:noreply, socket |> clear_flash()}
      end
    end
```

## Installation

```elixir
def deps do
  [
    {:live_view_flash_cleaner, git: "https://github.com/michalpaprocki/live_view_flash_cleaner"}
  ]
end
```


