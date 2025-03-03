# PulseSync

A decentralized scheduling application that helps teams sync their availability and manage project deadlines on the Stacks blockchain.

## Features
- Team member availability tracking
- Project deadline management
- Meeting scheduling with enhanced validation
- Conflict detection
- Event RSVP functionality
- Recurring meetings support
- Meeting notifications
- Meeting history tracking

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

### Enhanced Time Validation
The contract includes comprehensive time validation to ensure:
- End time must be later than start time
- Maximum meeting duration of 8 hours
- Minimum notification time of 5 minutes
- Applied to both meetings and availability settings
- Prevents invalid time slot entries

### Meeting History Tracking
- Tracks last modification time and modifier
- Maintains audit trail for meeting changes
- Supports historical meeting lookup

[... rest of original README content ...]
