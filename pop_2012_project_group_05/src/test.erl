-module(test).
-export([testar/2, init/2, fct/1, aircraft/3, spawnAircraft/5, testar2/1]).

init(Freq, Limit) -> 
	PID = spawn(fun() -> fct([]) end),
	io:format("FCT PID ~p~n", [PID]),
	aircraft(Freq, Limit, PID).

fct(FlightList) ->
	receive 
		{ok, PID} -> 
			NewFlightList = [{PID, 0}|FlightList],				
			io:format("PID2 ~p~n", [PID]),
			PID ! {ok, PID},
					%io:format("NEW ~p~n", [NewFlightList]),
			fct(NewFlightList);
		{request, PID} -> %io:format("landed ~p~n", [PID]),
						  %checkLanding(FlightList),
						  %{PID, YorN} = lists:keyfind(PID, 1, FlightList),
			Temp = lists:keyfind(1, 2, FlightList),
			io:format("fct TEMP ~p~p~n", [Temp, PID]),
				if 
					Temp =/= false -> 
					List = lists:keydelete(PID, 1, FlightList),
					io:format("request denied ~p~n", [Temp]),
					PID ! {self(), PID, deny},
					fct(List);
					true -> continue
				end,
			ChangedList = [{PID1, X+1} || {PID1, X} <- FlightList, PID == PID1],
			io:format("accepted ~p~n", [PID]),
			PID ! {self(), PID, accepted},
			fct(ChangedList);
		{landing, PID} -> 
			timer:sleep(5000),
			NewList = lists:keydelete(PID, 1, FlightList),
			PID ! {PID, landed},
			fct(NewList)
						  %io:format("fct TEMP ~p~n", [Temp]),
						  %ChangedList = [X+1 || {PID1, X} <- FlightList, PID == PID1],
						  %PID ! landing,
						  %timer:sleep(5000),
						  %NewList = lists:keydelete(PID, 1, ChangedList),
						  %PID ! {PID, landed, ok},
						  %io:format("Landed ~p~n", [PID]),
						  %ChangedList = lists:delete(PID, FlightList),
						  %PID ! {landed, PID},
						  %fct(NewList)
	end.

aircraft(Freq, Limit, PID) -> 
	case erlang:time() of
		Limit -> 
			timeOut;
		_     -> 
			timer:sleep(timer:seconds(Freq)),
			{H, M, S} = erlang:time(),
			Time = {H, M, S},
			LandingTime = {H, M, S+random:uniform(5)},
					%io:format("PID ~p~n", [PID]),
			PIDAIR = spawn(fun() -> spawnAircraft(LandingTime, Time, PID, Limit, Freq) end),
			io:format("PIDAIR ~p~n", [PIDAIR]),
					%timer:sleep(timer:seconds(Freq)),
			aircraft(Freq, Limit, PID)
							end.
				%	PID ! {ok, self()}.
				%spawn(fun() -> spawnAircraft(Time, LandingTime) end).

spawnAircraft(LandingTime, Time, PID, Limit, Freq) -> %io:format("PIDSAIR ~p~n", [self()]),
								%io:format("TIME ~p~n", [erlang:time()]),
								ThisPID = self(),
								io:format("PID1 ~p~n", [ThisPID]),
								case erlang:time() of 
								LandingTime -> PID ! {request, ThisPID},
												%io:format("TIME LANDING ~p~n", [erlang:time()]),
												%spawnAircraft(LandingTime, Time, PID);
												receive 
													%{PIDOK, landed, ok} -> {terminates, PIDOK};
													{PIDFCT, PIDACC, accepted} -> PIDFCT ! {landing, PIDACC},
																					receive
																						{PIDDONE, landed} -> 
																						io:format("Landed ~p~n", [PIDDONE])
																					end;
													{PIDFCT, PIDNOT, deny} -> io:format("Denied ~p~n", [PIDNOT]),
													{H, M, S} = erlang:time(),
													NewTime = {H, M, S+random:uniform(5)},
													spawnAircraft(LandingTime, NewTime, PIDFCT, Limit, Freq)
												end;
								Time        -> PID ! {ok, ThisPID},
												%io:format("TIME OK ~p~n", [erlang:time()]),
												io:format("KLAR1 ~p~n", [ThisPID]),
												receive 
													{ok, PID} ->
													io:format("KLAR2 ~p~n", [ThisPID]), 
													spawnAircraft(LandingTime, Time, PID, Limit, Freq)
												end;
								_           -> spawnAircraft(LandingTime, Time, PID, Limit, Freq)
									end.

testar2(LandingTime) -> case erlang:time() of 
								LandingTime -> ok;
								_           -> io:format("~p~n", [erlang:time()]), testar2(LandingTime)
						end.

testar(APA, Hej) when APA =:= 3 -> 3;
testar(Apa, Hej) ->
			{H, M, S} = erlang:time(),
			io:format("~p~n", [S]),
			io:format("~p~n", [erlang:time()]),
					Time = {H, M, S},
					io:format("~p~n", [Time]),
					io:format("~p~n", [erlang:time()]),
					StartingTime = {H, M, S},
					io:format("~p~n", [StartingTime]),
					io:format("~p~n", [erlang:time()]).
