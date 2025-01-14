# frozen_string_literal: true

SimpleCov.start :rails do
  enable_coverage :branch
  minimum_coverage line: 100, branch: 94.5 unless ENV["SKIP_COVERAGE"]

  add_filter "/lib/make_fixtures.rb"
end
