#!/usr/bin/env ruby -wKU
require 'rubygems/specification'
data = File.read('malline.gemspec')
spec = nil
Thread.new { spec = eval("$SAFE = 3\n#{data}") }.join
puts spec