# PulseSync

A decentralized scheduling application that helps teams sync their availability and manage project deadlines on the Stacks blockchain.

## Features
- Team member availability tracking
- Project deadline management
- Meeting scheduling with time validation
- Conflict detection
- Event RSVP functionality
- Recurring meetings support
- Meeting notifications

## Contract Functions
The smart contract provides the following functionality:
- Add/remove team members
- Set availability windows
- Create project deadlines
- Schedule meetings (one-time or recurring)
- Set meeting notifications
- RSVP to events
- Check schedule conflicts
- Validate meeting time slots

### Time Validation
The contract now includes time validation to ensure:
- End time must be later than start time
- Applied to both meetings and availability settings
- Prevents invalid time slot entries

### Recurring Meetings
Meetings can be scheduled with recurrence patterns:
- Frequency options: daily, weekly, monthly
- Custom intervals
- End date specification
- Notification reminders

### Meeting Notifications
Configure multiple notification reminders for meetings:
- Up to 5 notification times per meeting
- Timestamps relative to meeting start time
- Supports both one-time and recurring meetings
