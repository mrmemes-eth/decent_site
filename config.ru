require 'rubygems'
require 'bundler'

Bundler.require

require 'sinatra'
require 'haml'
require "sinatra/reloader" if development?

require './app'

run Sinatra::Application
