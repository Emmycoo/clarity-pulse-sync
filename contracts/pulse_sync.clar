;; PulseSync - Team Scheduling Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-conflict (err u103))
(define-constant err-invalid-recurrence (err u104))
(define-constant err-invalid-time (err u105))
(define-constant err-invalid-members (err u106))
(define-constant err-meeting-overlap (err u107))

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
    required-members: (list 10 principal),
    recurrence: (optional {
      frequency: (string-ascii 16),
      interval: uint,
      end-date: uint
    }),
    notifications: (list 5 uint),
    cancelled: bool
  }
)
(define-map rsvps
  { meeting-id: uint, member: principal }
  { attending: bool }
)

;; Data variables
(define-data-var project-id-nonce uint u0)
(define-data-var meeting-id-nonce uint u0)

;; Helper functions
(define-private (validate-time (start-time uint) (end-time uint))
  (if (> end-time start-time)
    (ok true)
    err-invalid-time
  )
)

(define-private (is-team-member (member principal))
  (default-to false (map-get? team-members member))
)

(define-private (validate-members (members (list 10 principal)))
  (begin
    (asserts! (> (len members) u0) err-invalid-members)
    (ok (fold check-member members true))
  )
)

(define-private (check-member (member principal) (valid bool))
  (and valid (is-team-member member))
)

(define-private (check-meeting-overlap (start-time uint) (end-time uint) (meeting-id uint))
  (let ((existing-meeting (map-get? meetings { id: meeting-id })))
    (match existing-meeting
      meeting (and
        (not (get cancelled meeting))
        (or
          (and (>= start-time (get start-time meeting)) (< start-time (get end-time meeting)))
          (and (> end-time (get start-time meeting)) (<= end-time (get end-time meeting)))
        )
      )
      false
    )
  )
)

;; Team member management 
(define-public (add-team-member (member principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set team-members member true))
  )
)

(define-public (remove-team-member (member principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-delete team-members member))
  )
)

;; Meeting management with enhanced validation
(define-public (schedule-meeting 
  (title (string-ascii 64)) 
  (start-time uint) 
  (end-time uint) 
  (required-members (list 10 principal))
  (recurrence (optional {
    frequency: (string-ascii 16),
    interval: uint,
    end-date: uint
  }))
  (notifications (list 5 uint))
)
  (begin
    (try! (validate-time start-time end-time))
    (try! (validate-members required-members))
    (let
      (
        (new-id (+ (var-get meeting-id-nonce) u1))
      )
      (asserts! (is-team-member tx-sender) err-unauthorized)
      (asserts! (not (check-meeting-overlap start-time end-time new-id)) err-meeting-overlap)
      (var-set meeting-id-nonce new-id)
      (ok (map-set meetings { id: new-id } 
        { 
          title: title,
          start-time: start-time,
          end-time: end-time,
          organizer: tx-sender,
          required-members: required-members,
          recurrence: recurrence,
          notifications: notifications,
          cancelled: false
        }
      ))
    )
  )
)

;; New function: Cancel meeting
(define-public (cancel-meeting (meeting-id uint))
  (let ((meeting (unwrap! (map-get? meetings { id: meeting-id }) err-not-found)))
    (begin
      (asserts! (or (is-eq tx-sender (get organizer meeting)) (is-eq tx-sender contract-owner)) err-unauthorized)
      (ok (map-set meetings { id: meeting-id }
        (merge meeting { cancelled: true })
      ))
    )
  )
)

[... rest of the original contract functions ...]
