Gem::Specification.new {|s|
	s.name = 'json-outstream'
	s.version = '0.1.0'
	s.licenses = ['MIT']
	s.summary = 'A streaming library for writing large json output'
	s.description = 'A library which provides a DSL for writing a large number of object as json without building the entire set in memory first.'
	s.homepage = 'https://github.com/ryanjamescalhoun/json-outstream'
	s.authors = ['Ryan Calhoun']
	s.email = ['ryanjamescalhoun@gmail.com']
	s.files = ['lib/json-outstream.rb', 'lib/json/outstream.rb', 'LICENSE.txt', 'README.md']
	s.test_files = ['test/test_outstream.rb', 'Rakefile']
}
