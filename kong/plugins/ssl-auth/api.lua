local crud = require "kong.api.crud_helpers"

return {
  ["/consumers/:username_or_id/ssl-auth/"] = {
    before = function(self, dao_factory, helpers)
      crud.find_consumer_by_username_or_id(self, dao_factory, helpers)
      self.params.consumer_id = self.consumer.id
    end,

    GET = function(self, dao_factory)
      crud.paginated_set(self, dao_factory.sslauth_credentials)
    end,

    PUT = function(self, dao_factory)
      crud.put(self.params, dao_factory.sslauth_credentials)
    end,

    POST = function(self, dao_factory)
      crud.post(self.params, dao_factory.sslauth_credentials)
    end
  },
  ["/consumers/:username_or_id/ssl-auth/:client_subject_or_id"] = {
    before = function(self, dao_factory, helpers)
      crud.find_consumer_by_username_or_id(self, dao_factory, helpers)
      self.params.consumer_id = self.consumer.id

      local credentials, err = crud.find_by_id_or_field(
        dao_factory.sslauth_credentials,
        { consumer_id = self.params.consumer_id },
        self.params.client_subject_or_id,
        "client_subject"
      )

      if err then
        return helpers.yield_error(err)
      elseif next(credentials) == nil then
        return helpers.responses.send_HTTP_NOT_FOUND()
      end
      self.params.client_subject_or_id = nil

      self.sslauth_credential = credentials[1]
    end,

    GET = function(self, dao_factory, helpers)
      return helpers.responses.send_HTTP_OK(self.sslauth_credential)
    end,

    PATCH = function(self, dao_factory)
      crud.patch(self.params, dao_factory.sslauth_credentials, self.sslauth_credential)
    end,

    DELETE = function(self, dao_factory)
      crud.delete(self.sslauth_credential, dao_factory.sslauth_credentials)
    end
  }
}
