-- Extending the Base Plugin handler is optional, as there is no real
-- concept of interface in Lua, but the Base Plugin handler's methods
-- can be called from your child implementation and will print logs
-- in your `error.log` file (where all logs are printed).
local BasePlugin = require "kong.plugins.base_plugin"
local SslAuthHandler = BasePlugin:extend()

KeyAuthHandler.PRIORITY = 1000

-- Your plugin handler's constructor. If you are extending the
-- Base Plugin handler, it's only role is to instanciate itself
-- with a name. The name is your plugin name as it will be printed in the logs.
function SslAuthHandler:new()
  SslAuthHandler.super.new(self, "ssl-auth")
  print("new - ssl-auth")
end

function SslAuthHandler:init_worker(config)
  -- Eventually, execute the parent implementation
  -- (will log that your plugin is entering this context)
  SslAuthHandler.super.init_worker(self)

  -- Implement any custom logic here
end

function SslAuthHandler:certificate(config)
  -- Eventually, execute the parent implementation
  -- (will log that your plugin is entering this context)
  SslAuthHandler.super.certificate(self)

  -- Implement any custom logic here
end

function SslAuthHandler:rewrite(config)
  -- Eventually, execute the parent implementation
  -- (will log that your plugin is entering this context)
  SslAuthHandler.super.rewrite(self)

  -- Implement any custom logic here
end

function SslAuthHandler:access(config)
  -- Eventually, execute the parent implementation
  -- (will log that your plugin is entering this context)
  SslAuthHandler.super.access(self)

  -- Implement any custom logic here
  print("access - ssl-auth")
end

function SslAuthHandler:header_filter(config)
  -- Eventually, execute the parent implementation
  -- (will log that your plugin is entering this context)
  SslAuthHandler.super.header_filter(self)

  -- Implement any custom logic here
end

function SslAuthHandler:body_filter(config)
  -- Eventually, execute the parent implementation
  -- (will log that your plugin is entering this context)
  SslAuthHandler.super.body_filter(self)

  -- Implement any custom logic here
end

function SslAuthHandler:log(config)
  -- Eventually, execute the parent implementation
  -- (will log that your plugin is entering this context)
  SslAuthHandler.super.log(self)

  -- Implement any custom logic here
end

-- This module needs to return the created table, so that Kong
-- can execute those functions.
return SslAuthHandler
