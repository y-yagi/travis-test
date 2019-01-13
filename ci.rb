#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
include FileUtils

system("psql --version")
system("sudo rabbitmqctl status")
