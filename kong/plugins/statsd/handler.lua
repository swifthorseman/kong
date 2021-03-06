local BasePlugin       = require "kong.plugins.base_plugin"
local basic_serializer = require "kong.plugins.log-serializers.basic"
local statsd_logger    = require "kong.plugins.statsd.statsd_logger"


local ngx_log       = ngx.log
local ngx_timer_at  = ngx.timer.at
local string_gsub   = string.gsub
local pairs         = pairs
local string_format = string.format
local NGX_ERR       = ngx.ERR


local StatsdHandler = BasePlugin:extend()
StatsdHandler.PRIORITY = 1


local get_consumer_id = {
  consumer_id = function(consumer)
    return consumer and string_gsub(consumer.id, "-", "_")
  end,
  custom_id   = function(consumer)
    return consumer and consumer.custom_id
  end,
  username    = function(consumer)
    return consumer and consumer.username
  end
}


local metrics = {
  status_count = function (api_name, message, metric_config, logger)
    local fmt = string_format("%s.request.status", api_name,
                       message.response.status)

    logger:send_statsd(string_format("%s.%s", fmt, message.response.status),
                       1, logger.stat_types.counter, metric_config.sample_rate)

    logger:send_statsd(string_format("%s.%s", fmt, "total"), 1,
                       logger.stat_types.counter, metric_config.sample_rate)
  end,
  unique_users = function (api_name, message, metric_config, logger)
    local get_consumer_id = get_consumer_id[metric_config.consumer_identifier]
    local consumer_id     = get_consumer_id(message.consumer)

    if consumer_id then
      local stat = string_format("%s.user.uniques", api_name)

      logger:send_statsd(stat, consumer_id, logger.stat_types.set)
    end
  end,
  request_per_user = function (api_name, message, metric_config, logger)
    local get_consumer_id = get_consumer_id[metric_config.consumer_identifier]
    local consumer_id     = get_consumer_id(message.consumer)

    if consumer_id then
      local stat = string_format("%s.user.%s.request.count", api_name, consumer_id)

      logger:send_statsd(stat, 1, logger.stat_types.counter,
                         metric_config.sample_rate)
    end
  end,
  status_count_per_user = function (api_name, message, metric_config, logger)
    local get_consumer_id = get_consumer_id[metric_config.consumer_identifier]
    local consumer_id     = get_consumer_id(message.consumer)

    if consumer_id then
      local fmt = string_format("%s.user.%s.request.status", api_name, consumer_id)

      logger:send_statsd(string_format("%s.%s", fmt, message.response.status),
                         1, logger.stat_types.counter,
                         metric_config.sample_rate)

      logger:send_statsd(string_format("%s.%s", fmt,  "total"),
                         1, logger.stat_types.counter,
                         metric_config.sample_rate)
    end
  end,
}


local function log(premature, conf, message)
  if premature then
    return

  end

  local api_name   = string_gsub(message.api.name, "%.", "_")
  local stat_name  = {
    request_size     = api_name .. ".request.size",
    response_size    = api_name .. ".response.size",
    latency          = api_name .. ".latency",
    upstream_latency = api_name .. ".upstream_latency",
    kong_latency     = api_name .. ".kong_latency",
    request_count    = api_name .. ".request.count",
  }
  local stat_value = {
    request_size     = message.request.size,
    response_size    = message.response.size,
    latency          = message.latencies.request,
    upstream_latency = message.latencies.proxy,
    kong_latency     = message.latencies.kong,
    request_count    = 1,
  }

  local logger, err = statsd_logger:new(conf)
  if err then
    ngx_log(NGX_ERR, "failed to create Statsd logger: ", err)
    return
  end

  for _, metric_config in pairs(conf.metrics) do
    local metric = metrics[metric_config.name]

    if metric then
      metric(api_name, message, metric_config, logger)

    else
      local stat_name = stat_name[metric_config.name]
      local stat_value = stat_value[metric_config.name]

      logger:send_statsd(stat_name, stat_value,
                         logger.stat_types[metric_config.stat_type],
                         metric_config.sample_rate)
    end
  end

  logger:close_socket()
end


function StatsdHandler:new()
  StatsdHandler.super.new(self, "statsd")
end


function StatsdHandler:log(conf)
  StatsdHandler.super.log(self)

  local message = basic_serializer.serialize(ngx)

  local ok, err = ngx_timer_at(0, log, conf, message)
  if not ok then
    ngx_log(NGX_ERR, "failed to create timer: ", err)
  end
end


return StatsdHandler
