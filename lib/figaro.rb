require "figaro/application"
require "figaro/env"

module Figaro
  extend self

  attr_writer :backend, :application

  def env
    Figaro::ENV
  end

  def backend
    @backend ||= Figaro::Application
  end

  def application
    @application ||= backend.new
  end

  def load
    application.load
  end
end
