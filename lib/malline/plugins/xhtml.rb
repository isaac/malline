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

# Quite stupid plugin for XHTML, we should be able to do this only with a DTD
# or similar.
#
# Defines all usable tags, list which one can be self-close, defines a short
# cut tag *xhtml*. Also makes sure that there is some necessary elements in
# the document.
class Malline::XHTML < Malline::Plugin
	CUSTOM_TAGS = %w{head title meta}

	# grep ELEMENT xhtml1-transitional.dtd | cut -d' ' -f2 | tr "\n" " "
	XHTML_TAGS = %w{html head title base meta link style script noscript iframe
		noframes body div p h1 h2 h3 h4 h5 h6 ul ol menu dir li dl dt dd address
		hr pre blockquote center ins del a span bdo br em strong dfn code samp
		kbd var cite abbr acronym q sub sup tt i b big small u s strike basefont
		font object param applet img map area form label input select optgroup
		option textarea fieldset legend button isindex table caption thead tfoot
		tbody colgroup col tr th td} - CUSTOM_TAGS

	# grep 'ELEMENT.*EMPTY' xhtml1-transitional.dtd | cut -d' ' -f2 | tr "\n" " "
	SHORT_TAG_EXCLUDES = XHTML_TAGS + CUSTOM_TAGS - %w{base meta link hr br
		basefont param img area input isindex col}

	module Tags
	 	def xhtml *args, &block
			attrs = { :xmlns => 'http://www.w3.org/1999/xhtml', 'xml:lang' => malline.options[:lang] }
			attrs.merge!(args.pop) if args.last.is_a?(Hash)

			self << "<?xml version=\"1.0\" encoding=\"#{malline.options[:encoding] || 'UTF-8'}\"?>\n"
			self << "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 #{malline.options[:xhtml_dtd] || 'Transitional'}//EN\"\n"
			self << "  \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-#{(malline.options[:xhtml_dtd] || 'Transitional').downcase}.dtd\">\n"

			tag! 'html', args.join(''), attrs, &block
		end

		def title *args, &block
			@__xhtml_title = true
			tag! 'title', *args, &block
		end

		def meta *args, &block
			@__xhtml_meta = true
			tag! 'meta', *args, &block
		end

		def head *args, &block
			@__xhtml_title = false
			proxy = tag! 'head', *args, &block
			proxy.__yld { title } unless @__xhtml_title
			proxy.__yld do
				meta :content => "text/html; charset=#{malline.options[:encoding] || 'UTF-8'}", 'http-equiv' => 'Content-Type'
			end unless @__xhtml_meta
		end
	end

	def self.do_install view
		view.malline.definetags! XHTML_TAGS
		view.malline.short_tag_excludes += SHORT_TAG_EXCLUDES
		view.extend Tags
	end
end
