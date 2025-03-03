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
(define-constant err-invalid-notifications (err u108))
(define-constant err-invalid-duration (err u109))

;; New constants for time constraints
(define-constant max-meeting-duration u480) ;; 8 hours in minutes
(define-constant min-notification-time u5) ;; 5 minutes
(define-constant max-historical-days u30) ;; 30 days

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
    cancelled: bool,
    last-modified: uint,
    modified-by: principal
  }
)
(define-map rsvps
  { meeting-id: uint, member: principal }
  { attending: bool }
)

;; Data variables
(define-data-var project-id-nonce uint u0)
(define-data-var meeting-id-nonce uint u0)

;; Enhanced helper functions
(define-private (validate-time (start-time uint) (end-time uint))
  (begin
    (asserts! (> end-time start-time) err-invalid-time)
    (asserts! (<= (- end-time start-time) max-meeting-duration) err-invalid-duration)
    (ok true)
  )
)

(define-private (validate-notifications (notifications (list 5 uint)) (start-time uint))
  (begin
    (asserts! (> (len notifications) u0) err-invalid-notifications)
    (asserts! (fold check-notification notifications true) err-invalid-notifications)
    (ok true)
  )
)

(define-private (check-notification (notification uint) (valid bool))
  (and 
    valid 
    (>= notification min-notification-time)
  )
)

;; [Previous helper functions remain unchanged]

;; Enhanced meeting scheduling
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
    (try! (validate-notifications notifications start-time))
    (let
      (
        (new-id (+ (var-get meeting-id-nonce) u1))
        (block-time block-height)
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
          cancelled: false,
          last-modified: block-time,
          modified-by: tx-sender
        }
      ))
    )
  )
)

;; Enhanced cancel meeting
(define-public (cancel-meeting (meeting-id uint))
  (let (
    (meeting (unwrap! (map-get? meetings { id: meeting-id }) err-not-found))
    (block-time block-height)
  )
    (begin
      (asserts! (or (is-eq tx-sender (get organizer meeting)) (is-eq tx-sender contract-owner)) err-unauthorized)
      (ok (map-set meetings { id: meeting-id }
        (merge meeting { 
          cancelled: true,
          last-modified: block-time,
          modified-by: tx-sender
        })
      ))
    )
  )
)

[... rest of the original contract functions ...]
