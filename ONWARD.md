# Onward fork of tracking_number

Onward installs this gem from our GitHub Packages registry, like `scorekeeper`, to recognize carriers upstream doesn't cover yet. `.github/workflows/gem-push.yml` builds and publishes it on every push to `onward`.

## What differs from upstream

- `lib/onward_data/couriers/*.json`: our carrier definitions, in the same format as upstream's `lib/data/couriers`. The `lib/data` submodule still points at upstream `jkeen/tracking_number_data`.
- `lib/tracking_number.rb` and `lib/tracking_number/loader.rb`: load both folders.
- `test/tracking_number_meta_test.rb`: runs every definition's test numbers from both folders.
- `test/onward_couriers_test.rb`: fails if our carriers stop loading or lose detection to another carrier.
- CI tests Ruby 3.3 and 4.0 (Onward runs 4.0). Upstream's release workflow is removed so nothing publishes to rubygems.org; `gem-push.yml` publishes to GitHub Packages instead.
- `tracking_number.gemspec` sets `allowed_push_host` to GitHub Packages, so `gem push` can't publish to rubygems.org.
- `lib/tracking_number/version.rb` is our published version. Upstream only sets the version when it builds a release, so its git source always reports 1.3.4.

## Adding a carrier

1. Add `lib/onward_data/couriers/<carrier>.json` with synthetic test numbers. This repo is public, so never use real customer tracking numbers.
2. Run `bundle exec rake test`.
3. Set `VERSION` in `lib/tracking_number/version.rb` to `X.Y.Z.onward.N`. The registry rejects a version it already has, so every merge to `onward` needs a new one.
4. Merge to `onward`, then bump the version in Onward's Gemfile once the publish job finishes.
5. Open the same definition upstream as a PR to `jkeen/tracking_number_data`. Delete it here once an upstream release includes it.

## Taking an upstream release

Merge the upstream tag into `onward` (it carries the `lib/data` submodule commit), run `git submodule update --init` and the tests, set `VERSION` to `X.Y.Z.onward.1`, merge, and bump the version in Onward's Gemfile. The gem is built from the `lib/data` submodule, so the publish workflow checks it out; a build without it ships none of upstream's carriers and raises no error.
