# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production with HTTPS support.
# Use with Kamal or build'n'run by hand:
# docker build -t ibekirov/wg_tg_bot:v1.1 .
# docker run -d -p 443:443 -e RAILS_MASTER_KEY=<value from config/master.key> --name wg_tg_bot ibekirov/wg_tg_bot:v1.1

FROM ruby:3.2.2-bullseye AS base

# Rails app lives here
WORKDIR /rails

# Install base packages, including openssl for SSL
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips libpq-dev postgresql-client openssl && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and assets
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev pkg-config nodejs && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Copy SSL certificates (assuming they are in config/ssl/)
COPY config/ssl/key.pem /rails/config/ssl/key.pem
COPY config/ssl/cert.pem /rails/config/ssl/cert.pem

RUN chmod +x bin/thrust bin/docker-entrypoint

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

RUN chmod +x /rails/bin/thrust /rails/bin/docker-entrypoint

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp bin/thrust bin/docker-entrypoint config/ssl

USER 1000:1000

# Entrypoint prepares the database
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server with SSL via Thruster on port 443
EXPOSE 443
CMD ["./bin/thrust", "./bin/rails", "server", "-b", "ssl://0.0.0.0:443?key=/rails/config/ssl/key.pem&cert=/rails/config/ssl/cert.pem"]
