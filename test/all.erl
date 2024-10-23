%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created :
%%%
%%% -------------------------------------------------------------------
-module(all).       
 
-export([start/0]).


%%
-define(CheckDelay,20).
-define(NumCheck,1000).


%% Change
-define(NodeName,"add_test").
-define(Application,"add_test").

-define(ApplicationName,"add_test").
-define(ApplicationDir,"add_test_container").
-define(TarFile,"add_test.tar.gz").
-define(TarDir,"tar_dir").
-define(ExecDir,"exec_dir").
-define(GitUrl,"https://github.com/joq62/add_test_arm.git ").

-define(Foreground,"./"++?ApplicationDir++"bin/"++?Application++" "++"foreground").
-define(Daemon,"./"++?ApplicationDir++"/bin/"++?Application++" "++"daemon").


%%
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
   
    ok=setup(),
    ok=test1(),

    file:del_dir_r(?ApplicationDir),   
    rpc:call(get_node(?NodeName),init,stop,[],5000),
    true=check_node_stopped(get_node(?NodeName)),
    io:format("Test OK !!! ~p~n",[?MODULE]),
    timer:sleep(2000),
    init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
test1()->    
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    %% Change
    42=rpc:call(get_node(?NodeName),add_test,add,[20,22],5000),
  {ok,"/home/ubuntu/arm_applications/test_area/add_test_orginal/add_test_container"}=rpc:call(get_node(?NodeName),add_test,get_cwd,[],5000),    
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
   
    file:del_dir_r(?ApplicationDir),
    file:make_dir(?ApplicationDir),
    _Clone=os:cmd("git clone "++" "++?GitUrl++" "++?ApplicationDir),
    %io:format("Clone ~p~n",[Clone]),
    %% Unpack tar file
    TarFileFullPath=filename:join([?ApplicationDir,?TarDir,?TarFile]),
    _Tar=os:cmd("tar -zxvf "++TarFileFullPath++" "++"-C"++" "++?ApplicationDir),
    %io:format("Tar ~p~n",[Tar]),
    rpc:call(get_node(?NodeName),init,stop,[],5000),
    true=check_node_stopped(get_node(?NodeName)),
    io:format("~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    %% Start application to test and check node started
    []=os:cmd(?Daemon),
    io:format("~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    true=check_node_started(get_node(?NodeName)),
    io:format("Node started ~p~n",[{get_node(?NodeName),?MODULE,?LINE}]),
    %% Check applications are correct started

    timer:sleep(2000),

    pong=rpc:call(get_node(?NodeName),log,ping,[],5000),
    pong=rpc:call(get_node(?NodeName),rd,ping,[],5000),

    %% Change
    pong=rpc:call(get_node(?NodeName),add_test,ping,[],5000),
    ok.


%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------




check_node_started(Node)->
    check_node_started(Node,?NumCheck,?CheckDelay,false).

check_node_started(_Node,_NumCheck,_CheckDelay,true)->
    true;
check_node_started(_Node,0,_CheckDelay,Boolean)->
    Boolean;
check_node_started(Node,NumCheck,CheckDelay,false)->
    case net_adm:ping(Node) of
	pong->
	    N=NumCheck,
	    Boolean=true;
	pang ->
	    timer:sleep(CheckDelay),
	    N=NumCheck-1,
	    Boolean=false
    end,
 %   io:format("NumCheck ~p~n",[{NumCheck,?MODULE,?LINE,?FUNCTION_NAME}]),
    check_node_started(Node,N,CheckDelay,Boolean).
    
%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------

check_node_stopped(Node)->
    check_node_stopped(Node,?NumCheck,?CheckDelay,false).

check_node_stopped(_Node,_NumCheck,_CheckDelay,true)->
    true;
check_node_stopped(_Node,0,_CheckDelay,Boolean)->
    Boolean;
check_node_stopped(Node,NumCheck,CheckDelay,false)->
    case net_adm:ping(Node) of
	pang->
	    N=NumCheck,
	    Boolean=true;
	pong ->
	    timer:sleep(CheckDelay),
	    N=NumCheck-1,
	    Boolean=false
    end,
 %   io:format("NumCheck ~p~n",[{NumCheck,?MODULE,?LINE,?FUNCTION_NAME}]),
    check_node_stopped(Node,N,CheckDelay,Boolean).    
    

get_node(NodeName)->
    {ok,Host}=net:gethostname(),
    list_to_atom(NodeName++"@"++Host).
