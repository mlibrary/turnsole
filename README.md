# Turnsole

[![Coverage Status](https://coveralls.io/repos/github/mlibrary/turnsole/badge.svg?branch=master)](https://coveralls.io/github/mlibrary/turnsole?branch=master)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/turnsole`. To experiment with that code, run `bin/console` for an interactive prompt.

Include the **Turnsole** gem in your Ruby shell scripts that query your [Heliotrope](https://github.com/mlibrary/heliotrope) application's REST API.
  
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'turnsole'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install turnsole

## Usage

Add these variables to your environment:

	export TURNSOLE_HELIOTROPE_API=http://localhost:3000/api
	export TURNSOLE_HELIOTROPE_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6Imdrb3N0aW5AdW1pY2guZWR1IiwicGluIjoiJDJhJDEwJElmcTNWTUt1YVd1eTIxWVM1Rk0ucnU5RExDemZuNWRyYS54OGgwZDJhcms3dFVhTkxHNnoyIn0.67Uk4mvM_ZuXn7YpYXPIdd7ygTBKaL_Er6fx2HM_AXg

**TURNSOLE_HELIOTROPE_API** is the URL to your [Heliotrope](https://github.com/mlibrary/heliotrope) application's API endpoint.

**TURNSOLE_HELIOTROPE_TOKEN** is the [JSON Web Token](https://jwt.io/) for your user account.

## Examples

### Handle Service

	$ ./bin/handle --help
	Usage: ./bin/handle noid
		-h, --help                       Print this help message

Converts a [noid](https://github.com/samvera/noid-rails) into a path, url, and retrieves its value
        
	$ ./bin/handle validnoid
	noid: validnoid
	path: 2027/fulcrum.validnoid
	url: https://hdl.handle.net/2027/fulcrum.validnoid
	value: 100 : Handle Not Found. (HTTP 404 Not Found)

### Heliotrope Service

	$ ./bin/heliotrope --help
	Usage: ./bin/heliotrope -v -p -c -d -s -g [-b <base>] [-t <token>]
    	-v, --verbose                    Verbose
    	-p, --products                   Products
    	-c, --components                 Components
    	-d, --individuals                Individuals
    	-s, --institutions               Institutions
    	-g, --grants                     Grants
    	-b, --base [url]                 URL to api
    	-t, --token [jwt]                JWT token
    	-h, --help                       Print this help message
    
Lists products, components, individuals, institutions and grants in your [Heliotrope](https://github.com/mlibrary/heliotrope) application.
        
	$ ./bin/heliotrope -p
	{"products"=>[{"id"=>118, "identifier"=>"product", "name"=>"Product", "purchase"=>"https::/purchase.com/product", "url"=>"http://localhost:3000/products/118.json"}]}

NOTE: **base** and **token** were obtained from the shell environment variables **TURNSOLE_HELIOTROPE_API** and **TURNSOLE_HELIOTROPE_TOKEN** respectively.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mlibrary/turnsole. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Turnsole project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mlibrary/turnsole/blob/master/CODE_OF_CONDUCT.md).
