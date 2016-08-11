defmodule Exradius.Data do
  @moduledoc """
  Extract records `nas_prop`, `radius_request`, `attribute` from eradius/include for using it from
  elixir code.
  """
  require Record

  Record.defrecord :nas_prop, Record.extract(:nas_prop, from_lib: "eradius/include/eradius_lib.hrl")
  Record.defrecord :radius_request, Record.extract(:radius_request, from_lib: "eradius/include/eradius_lib.hrl")

  Record.defrecord :attribute, Record.extract(:attribute, from_lib: "eradius/include/eradius_dict.hrl")
  Record.defrecord :vendor, Record.extract(:vendor, from_lib: "eradius/include/eradius_dict.hrl")
  Record.defrecord :value, Record.extract(:value, from_lib: "eradius/include/eradius_dict.hrl")

  ##- cmds
  defmacro r_access_request,      do:  1
  defmacro r_access_accept,       do:  2
  defmacro r_access_reject,       do:  3
  defmacro r_accounting_request,  do:  4
  defmacro r_accounting_response, do:  5
  defmacro r_access_challenge,    do:  11
  defmacro r_disconnect_request,  do:  40
  defmacro r_disconnect_ack,      do:  41
  defmacro r_disconnect_nak,      do:  42
  defmacro r_coa_request,         do:  43
  defmacro r_coa_ack,             do:  44
  defmacro r_coa_nak,             do:  45

  ##- attribs
  defmacro r_user_name,             do: 1
  defmacro r_user_passwd,           do: 2
  defmacro r_nas_ip_address,        do: 4
  defmacro r_reply_msg,             do: 18
  defmacro r_state,                 do: 24
  defmacro r_class,                 do: 25
  defmacro r_vendor_specific,       do: 26
  defmacro r_session_timeout,       do: 27
  defmacro r_idle_timeout,          do: 28
  defmacro r_status_type,           do: 40
  defmacro r_session_id,            do: 44
  defmacro r_session_time,          do: 46
  defmacro r_terminate_cause,       do: 49
  defmacro r_eap_message,           do: 79
  defmacro r_message_authenticator, do: 80

  ##- attribute values
  defmacro r_status_type_start,  do: 1
  defmacro r_status_type_stop,   do: 2
  defmacro r_status_type_update, do: 3  # interim-update
  defmacro r_status_type_on,     do: 7
  defmacro r_status_type_off,    do: 8

  ##- Terminate Cause values
  defmacro r_tc_user_request,    do: 1
  defmacro r_tc_idle_timeout,    do: 4
  defmacro r_tc_session_timeout, do: 5
  defmacro r_tc_admin_reset,     do: 6
  defmacro r_tc_admin_reboot,    do: 7
  defmacro r_tc_nas_request,     do: 10
  defmacro r_tc_nas_reboot,      do: 11
end
