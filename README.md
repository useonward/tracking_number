[![Ruby](https://github.com/jkeen/tracking_number/actions/workflows/ruby.yml/badge.svg)](https://github.com/jkeen/tracking_number/actions/workflows/ruby.yml)
[![Gem Version](https://badge.fury.io/rb/tracking_number.svg)](https://badge.fury.io/rb/tracking_number)
[![Gem](https://img.shields.io/gem/dt/tracking_number.svg)]()

## Onward fork

Onward's fork of [jkeen/tracking_number](https://github.com/jkeen/tracking_number), published to our GitHub Packages registry like `scorekeeper`, to recognize carriers upstream doesn't cover yet. `.github/workflows/gem-push.yml` runs the tests, then builds and publishes the gem whenever a push to `onward` changes `lib/tracking_number/version.rb`. Onward installs it inside the scoped `source "https://rubygems.pkg.github.com/useonward"` block in its Gemfile, so Bundler never resolves the public rubygems.org gem of the same name.

What differs from upstream:

- `lib/onward_data/couriers/*.json`: our carrier definitions, in the same format as upstream's `lib/data/couriers`. The `lib/data` submodule still points at upstream `jkeen/tracking_number_data`.
- `lib/tracking_number.rb` and `lib/tracking_number/loader.rb`: load both folders.
- `test/tracking_number_meta_test.rb` runs every definition's test numbers from both folders, and `test/onward_couriers_test.rb` fails if our carriers stop loading or lose detection to another carrier.
- `tracking_number.gemspec`: `allowed_push_host` limits `gem push` to GitHub Packages, and `github_repo` links the package to this repository.
- CI tests Ruby 3.3 and 4.0 (Onward runs 4.0). Upstream's release workflow is removed, so nothing publishes to rubygems.org.
- `lib/tracking_number/version.rb` is our published version, `X.Y.Z.N` on top of upstream's `X.Y.Z`. Bumping it is what releases: the registry rejects a version it already has, so the publish job only runs when this file changes.

Adding a carrier:

1. Add `lib/onward_data/couriers/<carrier>.json` with synthetic test numbers. This repo is public, so never use real customer tracking numbers.
2. Run `bundle exec rake test`.
3. Bump `VERSION`, merge to `onward`, and bump the version in Onward's Gemfile once the publish job finishes.
4. Open the same definition upstream as a PR to `jkeen/tracking_number_data`. Delete it here once an upstream release includes it.

Taking an upstream release: merge the upstream tag into `onward` (it carries the `lib/data` submodule commit), run `git submodule update --init` and the tests, set `VERSION` to `X.Y.Z.1`, merge, and bump Onward's Gemfile. The gem is built from the `lib/data` submodule, so a build without it ships none of upstream's carriers and raises no error. The publish job checks for that before it pushes.

## Tracking Number

This gem identifies valid tracking numbers and can tell you a little bit about the shipment just from the number—there's quite a bit of info tucked away into those numbers, it turns out.

It detects tracking numbers from USPS, UPS, FedEx, Amazon, DHL, OnTrac, LaserShip, Canada Post, DPD, Purolator, Old Dominion Freight Line, Spee-Dee Delivery, Canpar, YunExpress, Landmark Global, GOFO Express, and any carrier using the S10 international standard.

This gem does not do tracking. That is left up to you.

All the matching data is kept in [tracking_number_data](https://github.com/jkeen/tracking_number_data) and displayed in full on [trackingnumber.fyi](https://trackingnumber.fyi).

## Usage

#### Checking an individual tracking number
```ruby
t = TrackingNumber.new("MYSTERY_TRACKING_NUMBER")
# => #<TrackingNumber::Unknown MYSTERY_TRACKING_NUMBER>
t.valid? #=> false

t = TrackingNumber.new("1Z879E930346834440")
# => #<TrackingNumber::UPS 1Z879E930346834440>
t.valid? #=> true
```

#### Searching a block of text
This will return valid tracking numbers contained within a block of text.

```ruby
TrackingNumber.search("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, 1Z879E930346834440 nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 9611020987654312345672 dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")

#=> [#<TrackingNumber::UPS 1Z879E930346834440>, #<TrackingNumber::FedExGround96 9611020987654312345672>]
```

#### Courier Info
As of 1.0, the possible courier codes are `[:usps, :fedex, :ups, :ontrac, :dhl, :amazon, :s10, :unknown]`. S10 is the international standard used by local government post offices. When packages are shipped internationally via normal post, it's usually an S10 number.

```ruby
t = TrackingNumber.new("1Z879E930346834440")
# => #<TrackingNumber::UPS 1Z879E930346834440>

t.valid? #=> true
t.courier_code #=> :ups
t.courier_name #=> "UPS"


t = TrackingNumber.new("RB123456785GB")
t.courier_name #=> "Royal Mail Group plc"
t.courier_code #=> :s10

t = TrackingNumber.new("RB123456785US")
t.courier_name #=> "United States Postal Service"
```

#### Service Type
Some tracking numbers indicate their service type

```ruby
t = TrackingNumber.new("1Z879E930346834440")
t.service_type #=> "UPS United States Ground""

t = TrackingNumber.new("1ZXX3150YW44070023")
t.service_type #=> "UPS SurePost - Delivered by the USPS"

t = TrackingNumber.new("RB123456785US")
t.service_type #=> "Letter Post Registered"
```

#### Shipper ID
Some tracking numbers indicate information about their package
```ruby
t = TrackingNumber.new("1Z6072AF0320751583")
t.shipper_id #=> "6072AF" <-- this is Target
```

#### Destination Zip
Some tracking numbers indicate their destination

```ruby
t = TrackingNumber.new("1001901781990001000300617767839437")
t.destination_zip #=> "10003"
```

#### Package Info
Some tracking numbers indicate information about their package

```ruby
t = TrackingNumber.new("012345000000002")
t.package_type #=> "case/carton"
```

#### Tracking URL
Get the tracking url from the shipper
```ruby
t = TrackingNumber.new("1Z6072AF0320751583")
t.tracking_url #=> ""https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=1Z6072AF0320751583"
```

#### All the info we have
Get a object of all the info we have on the thing
```ruby
t = TrackingNumber.new("1Z6072AF0320751583")
t.info #=>  @courier=#<TrackingNumber::Info:0x000000010a45fed8 @code=:ups, @name="UPS">,
       #    @decode={:serial_number=>"6072AF032075158", :shipper_id=>"6072AF", :service_type=>"03", :package_id=>"2075158", :check_digit=>"3"},
       #    @destination_zip=nil,
       #    @package_type=nil,
       #    @partners=nil,
       #    @service_description=nil,
       #    @service_type="UPS United States Ground",
       #    @shipper_id="6072AF",
       #    @tracking_url="https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=1Z6072AF0320751583">
```

#### Decoding
Most tracking numbers have a format where each part of the number has meaning. `decode` splits up the number into its known named parts.
```ruby
  t = TrackingNumber.new("1Z879E930346834440")
  t.decode

  #=> {
  #  :serial_number => "879E93034683444",
  #  :shipper_id => "879E93",
  #  :service_type => "03",
  #  :package_id => "4683444",
  #  :check_digit => "0"
  # }   
```

## ActiveModel validation

For Rails 3 (or any ActiveModel client), validate your fields as a tracking number:
```ruby
class Shipment < ActiveRecord::Base
  validates :tracking, :tracking_number => true
end
```
Sometimes it's helpful to have a "magic" tracking number that isn't valid for any of the real carriers, and maybe will have other side effects (e.g., special treatment of a shipping email.)

```ruby
class Shipment < ActiveRecord::Base
  validates :tracking, :tracking_number => { :except => 'magic-hand-delivery' }
end
```

## Contributing to tracking_number
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2010-2021 Jeff Keen. See LICENSE.txt for
further details.
