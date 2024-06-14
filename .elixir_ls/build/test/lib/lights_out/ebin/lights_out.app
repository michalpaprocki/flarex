{application,lights_out,
    [{optional_applications,[]},
     {applications,[kernel,stdlib,elixir,logger]},
     {description,"lights_out"},
     {modules,
         ['Elixir.LightsOut','Elixir.LightsOut.Application',
          'Elixir.LightsOut.ProcessStore','Elixir.LightsOut.Supervisor']},
     {registered,[]},
     {vsn,"0.1.0"},
     {mod,
         {'Elixir.LightsOut.Application',
             [{strategy,one_for_one},{name,'Elixir.LightsOut.Supervisor'}]}}]}.