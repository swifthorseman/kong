local crud = require "kong.api.crud_helpers"
local reports = require "kong.core.reports"

return {
  ["/apis/"] = {
    GET = function(self, dao_factory)
      crud.paginated_set(self, dao_factory.apis)
    end,

    PUT = function(self, dao_factory)
      crud.put(self.params, dao_factory.apis)
    end,

    POST = function(self, dao_factory)
      crud.post(self.params, dao_factory.apis)
    end
  },

  ["/apis/:api_name_or_id"] = {
    before = function(self, dao_factory, helpers)
      crud.find_api_by_name_or_id(self, dao_factory, helpers)
    end,

    GET = function(self, dao_factory, helpers)
      return helpers.responses.send_HTTP_OK(self.api)
    end,

    PATCH = function(self, dao_factory)
      crud.patch(self.params, dao_factory.apis, self.api)
    end,

    DELETE = function(self, dao_factory)
      crud.delete(self.api, dao_factory.apis)
    end
  },

  ["/apis/:api_name_or_id/plugins/"] = {
    before = function(self, dao_factory, helpers)
      crud.find_api_by_name_or_id(self, dao_factory, helpers)
      self.params.api_id = self.api.id
    end,

    GET = function(self, dao_factory)
      crud.paginated_set(self, dao_factory.plugins)
    end,

    POST = function(self, dao_factory)
      crud.post(self.params, dao_factory.plugins, function(data)
        reports.send("api", data)
      end)
    end,

    PUT = function(self, dao_factory)
      crud.put(self.params, dao_factory.plugins)
    end
  },

  ["/apis/:api_name_or_id/plugins/:plugin_name_or_id"] = {
    before = function(self, dao_factory, helpers)
      crud.find_plugin_by_name_or_id(self, dao_factory, helpers)
    end,

    GET = function(self, dao_factory, helpers)
      return helpers.responses.send_HTTP_OK(self.plugin)
    end,

    PATCH = function(self, dao_factory)
      crud.patch(self.params, dao_factory.plugins, self.plugin)
    end,

    DELETE = function(self, dao_factory)
      crud.delete(self.plugin, dao_factory.plugins)
    end
  }
}
