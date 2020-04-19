FROM duodealer/rails

ENV BABEL_ENV production
ENV RAILS_ENV production
ENV NODE_OPTIONS --max-old-space-size=4096

ENV EXECJS_RUNTIME Node
RUN bundle exec rake assets:precompile
RUN bundle exec rails webpacker:compile
#RUN bundle exec rake cron:write
RUN touch /var/log/cron.log

COPY ./docker/entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# CMD bundle exec sidekiq -C config/sidekiq.yml

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-b", "unix:///tmp/puma.sock"]
