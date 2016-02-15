[![Gem Version](https://badge.fury.io/rb/outstream-json.svg)](http://badge.fury.io/rb/outstream-json)

# Outstream::Json

A library for producing JSON output in a streaming fashion. It is designed to work with lambdas and lazy enumerators, to minimize the need to create the entire JSON-encoding string at once.

## Installation

Add this line to your application's Gemfile:

    gem 'outstream-json'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install outstream-json

## Usage

The Json.create method defines a JSON object

	out = Outstream::Json.create do
	  ...
	end
	# use out.to_s or out.each to produce result

Use with basic ruby types

	Outstream::Json.create do
	  add string: "hello", number: 42
	  add array: [1,2,3]
	end
	# {"string":"hello","number":42,"array":[1,2,3]}

	Outstream::Json.create do
	  add "nested_object" {
	    add "foo" => "bar"
	  }
	end
	# {"nested_object":{"foo":"bar"}}

Use with transformed SQL result set

	client = Mysql2::Client.new
	results = client.query("SELECT * FROM hugetable", stream: true)
	Outstream::Json.create do
	  add results: results.lazy.map {|row| transform_row(row)}
	end
	# {"results":[{<transformed_result>},...]}

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
