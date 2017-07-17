local utils = require "kong.tools.utils"

local SCHEMA = {
  primary_key = {"id"},
  table = "sslauth_credentials",
  cache_key = { "client_subject" },
  fields = {
    id = {type = "id", dao_insert_value = true},
    created_at = {type = "timestamp", immutable = true, dao_insert_value = true},
    consumer_id = {type = "id", required = true, foreign = "consumers:id"},
    client_subject = {type = "string", required = true, unique = true}
  },
  marshall_event = function(self, t)
    return {id = t.id, consumer_id = t.consumer_id, client_subject = t.client_subject}
  end
}

return {sslauth_credentials = SCHEMA}
