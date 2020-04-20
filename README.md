<div align="center">
  <h1>Reverse Proxy App</h1>
  Reverse Proxy App is an application that enables caching and SSL for any website. This acts as a middleware layer between your domain and an origin host. The platform is a Ruby on Rails application with OpenResty, NGINX, and Kubernetes.
  <br/>
  <a href="https://app.ericsbookclub.com" target="_blank">View the demo here</a>
</div>

<br/>


----


## Main Features

## Usage

## Setting up Reverse Proxy App

### Prerequisites
Ensure that your local machine has the following dependencies installed.

* Ruby 2.7
* Postgres
* NodeJS
* Redis

## Testing

## Built With

- [Ruby on Rails](https://github.com/rails/rails) &mdash; Our back end is a Rails app.
- [OpenResty](https://github.com/openresty/openresty) &mdash; Our web server responsible for handling LetsEncrypt.
- [PostgreSQL](https://www.postgresql.org/) &mdash; Our main data store is in Postgres.
- [Redis](https://redis.io/) &mdash; We use Redis to persist SSL

Plus *lots* of Ruby Gems, a complete list of which is at [/master/Gemfile](https://github.com/ericraio/proxy-app/blob/master/Gemfile).
