-module(testserver).

-behaviour(gen_server).

-include("ra.hrl").

-export([start_link/0]).
-export([handle_call/3, handle_cast/2, terminate/2, init/1]).

start_link() ->
    gen_server:start_link({local, mytestserver}, ?MODULE, [], []).

init([]) ->
    {ok, #{}}.

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

terminate(Reason, _State) ->
    ?INFO("terminating because of ~p", [Reason]),
    ok.
