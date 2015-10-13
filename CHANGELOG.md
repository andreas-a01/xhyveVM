# Change Log
All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.3]
### Added   
- Support for network
    - use sudo for machines with network
    - sudo-askpass (via SUDO_ASKPASS) so no direct input is needed
    - ensure vm has a uuid
    - get mac address from uuid on first run
    - get ip adresse from system dhcpd_leases and mac_address
- .xhyvevm folder for uuid_file, mac_address, pid and console.pty
- Makefile to simplify setup

### Changed
- Rename config to xhyvevm.yml
- inspect shows uuid, ip, mac_address
- import now has better validation of archive
- VM Class - place use of `cat ` File.read
- VM Class - use privat run_command method insted of exec

### Fixed
- kill - now sent INT to whole process grub, no more zoomie VMs
- xhyve_wappers.sh deletes own pid file on EXIT
- rm now works
- VM Class don't access config hash directly

## [0.2]
### Added
- Check: Check config, dependences and VMs
- Logger now handler most message
- Better messages from script in general
- Debug messages before every system command.
- VM Class extended
- New VMconfig class, now handles config for VM
- Config is checked before being used
- some code clean up.

### Changed
- Kill: Does not run clean
- Import: Checks archive before import

### Fixed
- error in handling for aguments
- error in localOptions

## 0.1
- Initial release
- working with tinycore VM
- network is missing

[Unreleased]: https://github.com/andreas-a01/xhyveVM/compare/v0.3...HEAD
[0.3]: https://github.com/andreas-a01/xhyveVM/compare/v0.2...v0.3
[0.2]: https://github.com/andreas-a01/xhyveVM/compare/v0.1...v0.2
