# Turnsole

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

	export HELIOTROPE_BASE_URI=https://localhost:3000/api
	export HELIOTROPE_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6Imdrb3N0aW5AdW1pY2guZWR1IiwicGluIjoiJDJhJDEwJElmcTNWTUt1YVd1eTIxWVM1Rk0ucnU5RExDemZuNWRyYS54OGgwZDJhcms3dFVhTkxHNnoyIn0.67Uk4mvM_ZuXn7YpYXPIdd7ygTBKaL_Er6fx2HM_AXg

**HELIOTROPE_BASE_URI** is the URL to your [Heliotrope](https://github.com/mlibrary/heliotrope) application's REST API.

**HELIOTROPE_TOKEN** is the [JSON Web Token](https://jwt.io/) for your user account.

## Examples

### Handle Service

	./bin/handle_service --help
	Usage: ./bin/handle_service noid
        -h, --help                       Print this help message

Converts a [noid](https://github.com/samvera/noid-rails) into a path, url, and retrieves it value
        
	./bin/handle_service validnoid
    noid: validnoid
    path: 2027/fulcrum.validnoid
    url: http://hdl.handle.net/2027/fulcrum.validnoid
    value: 

### Heliotrope Service

	./bin/heliotrope_service --help
	Usage: ./bin/heliotrope_service -l -p [-b <base_uri>] [-t <token>] blah_blah_blah
        -b, --base [uri]                 URL to api
        -l, --lessees                    List lessees
        -p, --products                   List products
        -t, --token [jwt]                JWT token
        -h, --help                       Print this help message
        
Lists products and lessees in your [Heliotrope](https://github.com/mlibrary/heliotrope) application
        
	./bin/heliotrope_service -l -p blah_blah_blah
	{:parser=>HTTParty::Parser, :format=>:json, :base_uri=>"https://heliotrope-staging.hydra.lib.umich.edu/api", :headers=>{:authorization=>"Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6Imdrb3N0aW5AdW1pY2guZWR1IiwicGluIjoiLUtTNGVhSDR4bUkydVZHayJ9.Z5sHJoeuWyVClzX62L3x7hWcwc0s_ujm-ZAzXsRUlGw", :accept=>"application/json, application/vnd.heliotrope.v1+json", :content_type=>"application/json"}}
	blah_blah_blah
	{"id"=>1, "identifier"=>"Gabii", "name"=>nil, "url"=>"https://heliotrope-staging.hydra.lib.umich.edu/products/1.json"}
	{"id"=>6, "identifier"=>"1", "url"=>"https://heliotrope-staging.hydra.lib.umich.edu/lessees/6.json"}
	{"id"=>7, "identifier"=>"mbakeryo@umich.edu", "url"=>"https://heliotrope-staging.hydra.lib.umich.edu/lessees/7.json"}
	{"id"=>8, "identifier"=>"2", "url"=>"https://heliotrope-staging.hydra.lib.umich.edu/lessees/8.json"}
	{"id"=>9, "identifier"=>"sethajoh@umich.edu", "url"=>"https://heliotrope-staging.hydra.lib.umich.edu/lessees/9.json"}

NOTE: **base_uri** and **token** obtained from environment.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mlibrary/turnsole. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Turnsole project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/turnsole/blob/master/CODE_OF_CONDUCT.md).
