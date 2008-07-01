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

# Malline very incomplete Plugin interface.
class Malline::Plugin
	# Install a new plugin: Malline::WhatEverPlugin.install view
	def self.install view
		return if view.malline.plugins.include? self
		self.do_install view
		view.malline.plugins << self
	end

	protected
	def self.do_install view
		raise NotImplementedError.new
	end
	def self.do_uninstall view
		raise NotImplementedError.new("#{self} cannot be uninstalled")
	end
end
