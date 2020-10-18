not_declared_trivial = !(github.pr_title.include? "#trivial")
no_changelog_entry = !git.modified_files.include?("CHANGELOG.md")

all_edited_files = (git.modified_files + git.added_files).select do |line|
  line.end_with?(".swift") || line.end_with?(".h") || line.end_with?(".modulemap")
end

has_sources_changes = !all_edited_files.grep(/Sources/).empty?
has_tests_changes = !all_edited_files.grep(/Tests/).empty?

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR, try to keep changes smaller if you can") if git.lines_of_code > 300

# Changelog entries are required for changes to library files.
if not_declared_trivial && no_changelog_entry && has_sources_changes
  warn("Any changes to library code should be reflected in the CHANGELOG. \nPlease consider adding a note there about your change.")
end

# Warn when library files has been updated but not tests.
if has_sources_changes && !has_tests_changes
  warn("The library files were changed, but the tests remained unmodified. \nConsider updating or adding to the tests to match the library changes.")
end

# Run Swiftlint.
github.dismiss_out_of_range_messages
swiftlint.config_file = ".swiftlint.yml"
swiftlint.lint_files inline_mode: true
