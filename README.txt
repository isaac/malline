= Malline 1.1.0-svn

* http://www.malline.org/

== DESCRIPTION:

Malline is a full-featured template system designed to be
a replacement for ERB views in Rails or any other framework.
It also includes standalone bin/malline to compile Malline
templates to XML in commandline. All Malline templates are
pure Ruby, see http://www.malline.org/ for more info.

See documentation on http://www.malline.org/

Copyright © 2007,2008 Riku Palomäki, riku@palomaki.fi
Malline is released under GNU Lesser General Public License.


Example Rails template file images.html.mn:

	xhtml do
		_render :partial => 'head'
		body do
			div.images! "There are some images:" do
				images.each do |im|
					a(:href => img_path(im)) { img :src => im.url }
					span.caption im.caption
				end
				_"No more images"
			end
			div.footer! { _render :partial => 'footer' }
		end
	end
