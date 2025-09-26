-module(mod_sasl_external_common_name_prefix).
-behaviour(cyrsasl_external).

%% API
-export([verify_creds/1]).

-include("mongoose_logger.hrl").

-spec verify_creds(Creds :: mongoose_credentials:t()) ->
    {ok, Username :: binary()} | {error, Error :: binary()}.

verify_creds(Creds) ->
    Server = mongoose_credentials:lserver(Creds),
    AuthId = mongoose_credentials:get(Creds, auth_id, undefined),
    CommonName = mongoose_credentials:get(Creds, common_name, undefined),

    case {AuthId, CommonName} of
        {undefined, CN} when is_binary(CN) ->
            % No auth_id provided, use CN with prefix
            Username = <<"k21gateway_", CN/binary>>,
            {ok, Username};
        {_, undefined} ->
            ?LOG_ERROR(#{what => mod_custom_sasl_no_common_name,
                         auth_id => AuthId,
                         server => Server}),
            {error, <<"not-authorized">>};
        _ ->
            ?LOG_ERROR(#{what => mod_custom_sasl_invalid_credentials,
                         auth_id => AuthId,
                         common_name => CommonName,
                         server => Server}),
            {error, <<"not-authorized">>}
    end.
