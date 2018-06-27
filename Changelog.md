# Changelog
All notable changes to this project will be documented in this file.
## [0.3.1] - 2018-06-27
### Fixed 
    - Wrond request scope in result_sets_by_status
### Changes 
    - result_sets_by_status will return empty array of result sets and status_error is status not found
## [0.3.0] - 2018-04-05
### Added
    - New method to api: gettind result_sets by statuses and etc. data
## [0.2.1] - 2018-03-28
### Changed
    - Min password size
### Fixed
    - Error after change product positions
    - Send error it registration email is already taken
## [0.2.0] - 2018-03-28
### Changed
    - All '/' methods is in 'public' namespace now
## [0.1.1] - 2018-03-2
### Added 
    - Oppotrunity to save product position in list
## [0.1.0] - 2018-02-15
### Added
    - Add errors after creating product without name
    - Test for product validation
    - Chanre respons of most part requests for errors chechs
### Fixed
    - Fix errors after muliple result adding by case name or case id
### Fixed
    - Fix errors after name change
## [0.0.1] - 2018-01-30
### Fixed
    - Fixed error after uncorect product name from edit product method
### Added
    - Rubocop files for code style 
    - Changelog file
    - Public method `version`. In return curent version of application
    - Add test for `version` method