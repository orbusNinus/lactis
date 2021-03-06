# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed
### Fixed

## [2.0] 
### Added
- Added functionality to export and import MCM settings (note that this does 
  NOT include actor offsets for now).
- Added LICENSE file. 
### Changed
- Refactored mod to use only one single armor which contains the armatures for
  the left and right nipple squirt effect. This results in faster equipping 
  times and much simpler code.
- Removed unused sound record from esp.


## [1.1] - 2021-10-31
### Added
### Changed
- Increased the y- and z-axis offset range.
- Removed console debug output.
### Fixed
- Fixed offset alignment of left nipple squirt effect when played during an
  OStim scene. 

## [1.0] - 2021-09-17 - github release
### Added
- Added per NPC nipple squirt effect offset and scale configuration 
  functionality.
- Added an uninstall option to MCM.
### Changed
- Refactored API for easier integration into other mods.
- Optimized MCM menu.
- Removed some properties from esp, which are now purely script controlled.
### Fixed
- Fixed initialization of running effects on game load.
- Fixed OStim enabled option toggling in MCM.
  Lactis now correctly un/registers from/to OStim events when "OStim enabled"
  option in MCM is toggled.
- Fixed "Save corrupted" bug on uninstall.

## [0.4] - 2021-08-17 - nexusmods release
### Added
- Added forced nipple squirt removal.

## [0.31] - 2021-07-21 - Initial github release
