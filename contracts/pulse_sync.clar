;; PulseSync - Team Scheduling Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-conflict (err u103))

;; Data structures
(define-map team-members principal bool)
(define-map availability 
  { member: principal, day: uint }
  { start-time: uint, end-time: uint }
)
(define-map projects 
  { id: uint }
  { name: (string-ascii 64), deadline: uint, owner: principal }
)
(define-map meetings
  { id: uint }
  { 
    title: (string-ascii 64),
    start-time: uint,
    end-time: uint,
    organizer: principal,
    required-members: (list 10 principal)
  }
)
(define-map rsvps
  { meeting-id: uint, member: principal }
  { attending: bool }
)

;; Data variables
(define-data-var project-id-nonce uint u0)
(define-data-var meeting-id-nonce uint u0)

;; Team member management
(define-public (add-team-member (member principal))
  (if (is-eq tx-sender contract-owner)
    (ok (map-set team-members member true))
    err-owner-only
  )
)

(define-public (remove-team-member (member principal))
  (if (is-eq tx-sender contract-owner)
    (ok (map-delete team-members member))
    err-owner-only
  )
)

;; Availability management
(define-public (set-availability (day uint) (start-time uint) (end-time uint))
  (if (default-to false (map-get? team-members tx-sender))
    (ok (map-set availability { member: tx-sender, day: day } { start-time: start-time, end-time: end-time }))
    err-unauthorized
  )
)

;; Project management
(define-public (create-project (name (string-ascii 64)) (deadline uint))
  (let
    (
      (new-id (+ (var-get project-id-nonce) u1))
    )
    (if (default-to false (map-get? team-members tx-sender))
      (begin
        (var-set project-id-nonce new-id)
        (ok (map-set projects { id: new-id } { name: name, deadline: deadline, owner: tx-sender }))
      )
      err-unauthorized
    )
  )
)

;; Meeting management
(define-public (schedule-meeting (title (string-ascii 64)) (start-time uint) (end-time uint) (required-members (list 10 principal)))
  (let
    (
      (new-id (+ (var-get meeting-id-nonce) u1))
    )
    (if (default-to false (map-get? team-members tx-sender))
      (begin
        (var-set meeting-id-nonce new-id)
        (ok (map-set meetings { id: new-id } 
          { 
            title: title,
            start-time: start-time,
            end-time: end-time,
            organizer: tx-sender,
            required-members: required-members
          }
        ))
      )
      err-unauthorized
    )
  )
)

;; RSVP functionality
(define-public (rsvp-to-meeting (meeting-id uint) (attending bool))
  (if (default-to false (map-get? team-members tx-sender))
    (ok (map-set rsvps { meeting-id: meeting-id, member: tx-sender } { attending: attending }))
    err-unauthorized
  )
)

;; Read-only functions
(define-read-only (get-member-availability (member principal) (day uint))
  (map-get? availability { member: member, day: day })
)

(define-read-only (get-meeting-details (meeting-id uint))
  (map-get? meetings { id: meeting-id })
)

(define-read-only (get-project-details (project-id uint))
  (map-get? projects { id: project-id })
)

(define-read-only (get-rsvp-status (meeting-id uint) (member principal))
  (map-get? rsvps { meeting-id: meeting-id, member: member })
)