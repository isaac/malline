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
require 'malline/view_xhtml.rb'
require 'malline/erb_out.rb'
require 'malline/form_builder.rb'
require 'malline/template.rb'

module Malline
	# Always form ^\d+\.\d+\.\d+(-[^\s]*)?$
	VERSION = '1.0.3-svn'

	# Template-handler class that is registered to ActionView and initialized by it.
	class Base < (defined?(ActionView) ? ActionView::TemplateHandler : Object)
		# Default options for new instances, can be changed with setopt
		@@options = { :strict => true, :xhtml => true, :encoding => 'UTF-8', :lang => 'en', :form_for_proxy => true }
		attr_reader :view

		# First parameter is the view object (if any)
		# Last parameter is optional options hash
		def initialize(*opts)
			@options = @@options.dup
			@options.merge! opts.pop if opts.last.is_a?(Hash)

			@view = opts.shift || Class.new
			unless @view.is_a?(ViewWrapper)
				@view.extend ViewWrapper
				@view.malline @options
				Malline::XHTML.load_plugin self if @options[:xhtml]
			else
				@view.malline @options
			end

			if @options[:form_for_proxy]
				begin
					ActionView::Base.default_form_builder = ::Malline::FormBuilder
				rescue NameError
				end
			end
		end

		def set_path path
			@view.malline.path = path
		end

		def self.setopt hash
			output = nil
			if block_given?
				o = @@options.dup
				@@options.merge!(hash) if hash
				begin
					output = yield
				ensure
					@@options = o
				end
			else
				@@options.merge!(hash)
			end
			output
		end

		# n is there to keep things compatible with Markaby
		def render tpl = nil, local_assigns = {}, n = nil, &block
			add_local_assigns local_assigns
			@view.malline_is_active = true
			@view.malline.run tpl, &block
		end

		def self.render tpl = nil, local_assigns = {}, &block
			self.new.render(tpl, local_assigns, &block)
		end

		def definetags *args
			@view.malline.definetags *args
		end

		def definetags! *args
			@view.malline.definetags! *args
		end

		private
		def add_local_assigns l
			@view.instance_eval do
				l.each { |key, value| instance_variable_set "@#{key}", value }
				evaluate_assigns if respond_to?(:evaluate_assigns, true)
				class << self; self; end.send(:attr_accessor, *(l.keys))
			end
		end
	end
end
