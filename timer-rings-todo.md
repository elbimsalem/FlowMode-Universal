# Timer Rings Modification - Todo List

## High Priority Tasks

- [ ] **Task 1**: Analyze current ring progress calculation logic in TimerService.swift:47-67
- [ ] **Task 2**: Create new ring display model where 1 ring = 60 minutes for both work and pause timers
- [ ] **Task 3**: Add multiple ring support to TimerProgressRing.swift for displaying additional rings when >60min elapsed
- [ ] **Task 5**: Update progress calculation logic to support 60-minute ring segments

## Medium Priority Tasks

- [ ] **Task 4**: Implement max work time visualization as light gray ring overlay
- [ ] **Task 6**: Handle ring positioning and sizing for multiple rings (inner work, outer pause)
- [ ] **Task 7**: Update animation logic to work with multi-ring display system

## Low Priority Tasks

- [ ] **Task 8**: Test the new ring system with various time durations (30min, 60min, 90min, 120min)
- [ ] **Task 9**: Ensure theme integration works correctly with new multi-ring display

## Implementation Notes

### Current System:
- Single inner ring (work progress) based on max work time or 8-hour reference
- Single outer ring (pause progress) shows accumulated break percentage
- Max work time shown as background ring (light gray) under progress ring

### New System Requirements:
- Each ring represents 60 minutes
- Multiple rings stack: inner rings for work time, outer rings for pause time
- Max work time remains as light gray background under active progress ring
- Additional rings appear when time exceeds 60-minute segments

### Key Files:
- `TimerService.swift:47-67` - Progress calculation logic
- `TimerProgressRing.swift` - Ring rendering component
- `TimerView.swift:42-46` - Timer integration