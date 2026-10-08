# Onward fork of tracking_number

Onward installs this gem from git (`useonward/tracking_number`, branch `onward`, pinned by tag) to recognize carriers upstream doesn't cover yet.

## What differs from upstream

- `lib/onward_data/couriers/*.json`: our carrier definitions, in the same format as upstream's `lib/data/couriers`. The `lib/data` submodule still points at upstream `jkeen/tracking_number_data`.
- `lib/tracking_number.rb` and `lib/tracking_number/loader.rb`: load both folders.
- `test/tracking_number_meta_test.rb`: runs every definition's test numbers from both folders.
- CI tests the Ruby versions Onward runs, and the release workflow is removed so pushes never publish to rubygems.

## Adding a carrier

1. Add `lib/onward_data/couriers/<carrier>.json` with synthetic test numbers. This repo is public, so never use real customer tracking numbers.
2. Run `bundle exec rake test`.
3. Tag `vX.Y.Z-onward.N` and bump the tag in Onward's Gemfile.
4. Open the same definition upstream as a PR to `jkeen/tracking_number_data`. Delete it here once an upstream release includes it.

## Taking an upstream release

Merge the upstream tag into `onward`, update the `lib/data` submodule to the tag's commit, run the tests, tag `vX.Y.Z-onward.1`, and bump the tag in Onward's Gemfile. Install with `submodules: true`. Without it the gem loads no carriers, and it raises no error.
