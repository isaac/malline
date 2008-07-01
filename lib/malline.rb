# Copyright © 2007,2008 Riku Palomäki
#
# This file is part of Malline.
#
# Malline is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Malline is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Malline.  If not, see <http://www.gnu.org/licenses/>.

require 'malline/view_proxy.rb'
require 'malline/view_wrapper.rb'
require 'malline/erb_out.rb'
require 'malline/template.rb'
require 'malline/plugin.rb'
require 'malline/plugins/xhtml.rb'

module Malline
	# Always form ^\d+\.\d+\.\d+(-[^\s]*)?$
	VERSION = '1.1.0-svn'

	# Malline handler, always use Malline engine with this
	# 	handler = Malline.new @view, :strict => false
	# 	handler.
	class Base
		attr_accessor :malline

		# Default options, can be changed with setopt
		@@options = {
			:strict => true,
			:xhtml => true,
			:encoding => 'UTF-8',
			:lang => 'en',
			:form_for_proxy => true
		}

		# First parameter is the view object (if any)
		# Last parameter is optional options hash
		def initialize *opts
			@options = @@options.dup
			@options.merge! opts.pop if opts.last.is_a?(Hash)

			@view = opts.shift || Class.new
			@view.extend ViewWrapper unless @view.is_a?(ViewWrapper)
			@malline = @view.malline @options
		end

		# Get the current filename
		def path 
			@view.malline.path
		end

		def path= npath
			@view.malline.path = npath
		end

		# for example:
		# 	setopt :strict => false
		#
		# or:
		# 	setopt :strict => false
		#		something
		# 	setopt :strict => true do
		#   	something strict
		# 	end
		def self.setopt hash
			return @@options.merge!(hash) unless block_given?
			old = @@options.dup
			@@options.merge! hash if hash
			yield
		ensure
			@@options = old if old
		end

		def render tpl = nil, local_assigns = {}, &block
			add_local_assigns local_assigns
			@view.malline.run tpl, &block
		end

		def self.render tpl = nil, local_assigns = {}, &block
			self.new.render tpl, local_assigns, &block
		end

		def definetags *args
			@view.malline.definetags *args
		end

		def definetags! *args
			@view.malline.definetags! *args
		end

		private
		# Define hash as instance variables, for example { :foo => 'bar' }
		# will work as @foo == 'bar' and foo == 'bar'
		def add_local_assigns l
			@view.instance_eval do
				l.each { |key, value| instance_variable_set "@#{key}", value }
				class << self; self; end.send(:attr_accessor, *(l.keys))
			end
		end
	end
end
