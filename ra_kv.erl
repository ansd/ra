-module(ra_kv).
-behaviour(ra_machine).
-compile(debug_info).

-export([init/1, apply/3, start/0]).

init(_Conf) ->
    #{}.

apply(_Meta, {write, K, V}, S0) ->
    S = maps:put(K, V, S0),
    {S, ok, [myeffect, {send_msg, console, hello, local}]};
apply(_Meta, {read, K}, S) ->
    V = maps:get(K, S, undefined),
    {S, V, []}.

start() ->
    Members = ['r1@<my_host_fqdn>', 'r2@<my_host_fqdn>', 'r3@<my_host_fqdn>'],
    [pong, pong, pong] = [net_adm:ping(M) || M <- Members],
    [rpc:call(M, ra, start, []) || M <- Members],

    ClusterName = mkv,
    Machine = {module, ?MODULE, #{}},
    ServerIds = [{s, M} || M <- Members],
    ServerConfigs = [begin
                         Prefix = ra_lib:derive_safe_string(ra_lib:to_binary(ClusterName), 6),
                         UId = ra_lib:make_uid(string:uppercase(Prefix)),
                         #{id => Id,
                           uid => UId,
                           cluster_name => ClusterName,
                           initial_members => ServerIds,
                           machine => Machine,
                           log_init_args => #{uid => UId},
                           leader_companion_config => #{start => {testserver, start_link, []},
                                                        type => worker,
                                                        modules => [testserver]}}
                     end || Id <- ServerIds],
    ra:start_cluster(default, ServerConfigs).

    % Config = #{leader_companion_config => #{start => {testserver, start_link, []},
                                            % type => worker,
                                            % modules => [testserver]}},
    % Machine = {module, ?MODULE, #{}},
    % ClusterName = mkv,
    % ServerIds = [{s, M} || M <- Members],
    %% start a cluster instance running the `ra_kv` machine
    % ra:start_cluster(default, ClusterName, Machine, ServerIds).

% ClusterName2 = mkv2,
% ServerIds2 = [{s2, M} || M <- Members],
% start a cluster instance running the `ra_kv` machine
% ra:start_cluster(default, ClusterName2, Machine, ServerIds2).
