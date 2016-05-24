# Change Log
All notable changes to this project will be documented in this file.
`JTAppleCalendar` adheres to [Semantic Versioning](http://semver.org/).

#### 3.x Releases
- `3.0.0` Releases - [3.0.0](#300)|[3.0.1](#301)

#### 2.x Releases
- `2.1.0` Releases - [2.1.0](#210)|[2.1.1](#211)|[2.1.2](#212)
- `2.0.0` Releases - [2.0.0](#200)|[2.0.1](#201)|[2.0.2](#202)|[2.0.3](#203)

#### 1.x Releases
- `1.1.x` Releases - [1.1.0](#110)| [1.1.1](#111)
- `1.0.x` Releases - [1.0.0](#100)

---
## [3.0.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/3.0.1)
- Fixed issue: Cell Inset was borken with 3.0.0 release
- Fixed issue: canSelectDate always returned true. 
  - Updated by [JayT](https://github.com/patchthecode).
  
## [3.0.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/3.0.0)
- Fixed: Issue [#20](https://github.com/patchthecode/JTAppleCalendar/issues/20). Layout should be set to needsUpdate when firstDayOfWeek changes
- Update: Issue [#19](https://github.com/patchthecode/JTAppleCalendar/issues/19). DidScroll delegate will now only get called when user scolls. This makes clear system actions vs user actions.
- Fixed: Issue [#18](https://github.com/patchthecode/JTAppleCalendar/issues/18). Selecting out-dates now also select their date counterparts.
- Update: Issue [#16](https://github.com/patchthecode/JTAppleCalendar/issues/16). Headers are now added to the project.
  - Updated by [JayT](https://github.com/patchthecode).

## [2.1.2](https://github.com/patchthecode/JTAppleCalendar/releases/tag/2.1.2)
- Fixed: When selecting date with delegates disabled, calendar shifted to month offset. This was due to the newly added smooth scrolling feature
- Update: The CellState for a date now returns more information. It now returns (added to its previous info) a date and a day.
- Update: New function added so user can query the visible dateCells on the screen: cellStatusForDateAtRow(_: Int, column: Int)
- Update: With paging disbled, the scrolling now snaps to day
  - Updated by [JayT](https://github.com/patchthecode).

## [2.1.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/2.1.1)
- Crash on using NSDate() without a formatter for date ranges [Issue 11](https://github.com/patchthecode/JTAppleCalendar/issues/11)
  - Updated by [JayT](https://github.com/patchthecode).

## [2.1.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/2.1.0)
- Calendar paging is now an option
- Scroll to date method will now scroll to a date if paging is set to off. [Issue 10](https://github.com/patchthecode/JTAppleCalendar/issues/10)
  - Updated by [JayT](https://github.com/patchthecode).


## [2.0.3](https://github.com/patchthecode/JTAppleCalendar/releases/tag/2.0.3)
- Fixed visual bug. Now there should be no flickering when scrolling dates.
- Updated sample code 
  - Updated by [JayT](https://github.com/patchthecode).


## [2.0.2](https://github.com/patchthecode/JTAppleCalendar/releases/tag/2.0.2)
- Added functionality to not trigger delegates on selecting dates
- Updated sample code 
  - Updated by [JayT](https://github.com/patchthecode).


## [2.0.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/2.0.0)
- Added function to handle date selection in Arrays
  - Updated by [JayT](https://github.com/patchthecode).


## [2.0.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/2.0.0)
Released on 2016-04-5. All issues associated with this milestone can be found using this 
[filter](https://github.com/patchthecode/JTAppleCalendar/milestones/Obvious%20things%20that%20were%20missed%20in%20Initial%20Coding)

#### Updated
- fixed date selection method. 
- made didSelectDate function return an optional object. The value can be nil if the selected date is off the screen.
  - Updated by [JayT](https://github.com/patchthecode).


## [1.1.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/1.1.1)
Released on 2016-03-20.

#### Updated
- Updated packages
- Updated by [JayT](https://github.com/patchthecode).


## [1.1.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/1.1.0)
Released on 2016-03-28.

#### Updated
- Added functionality to query current date section
- Calendar-view now reloads on datasource change
  - Updated by [JayT](https://github.com/patchthecode).


## [1.0.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/1.0.0)
Released on 2016-03-27.

#### Added
- Initial release of JTAppleCalendar.
  - Added by [JayT](https://github.com/patchthecode).
