#!/usr/bin/env rake
# frozen_string_literal: true

desc 'Task to add tag with version to repo'
task :add_repo_tag do
  version = "v#{File.read('VERSION')}".strip
  `git tag -a #{version} -m "#{version}"`
  `git push --tags`
end
