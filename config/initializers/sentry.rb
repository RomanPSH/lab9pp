Sentry.init do |config|
  config.dsn = "https://99fba6a1475b0cba12636260adcd17f9@o4509363113230336.ingest.de.sentry.io/4509363118735440"
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]

  config.environment = Rails.env
  config.enabled_environments = %w[development production]
end
