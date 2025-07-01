;; Title: BitFlow - Bitcoin-Native Donation Management Protocol
;;
;; Summary: A decentralized charity platform leveraging Bitcoin's security
;;          to create transparent, milestone-driven philanthropy
;;
;; Description: BitFlow transforms charitable giving through Bitcoin's immutable
;;              ledger technology. Our protocol enables direct community impact
;;              tracking with cryptographic proof of fund allocation. Every
;;              donation flows through transparent milestones, ensuring donors
;;              witness real-world outcomes while beneficiaries access capital
;;              through verified achievement gates. Built on Stacks Layer 2 for
;;              Bitcoin-backed security with zero-trust verification systems.

;; CONTRACT CONFIGURATION

;; Immutable contract deployer - secured by Bitcoin finality
(define-data-var contract-owner principal tx-sender)

;; ERROR CONSTANTS

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-REGISTERED (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-BENEFICIARY-NOT-FOUND (err u104))
(define-constant ERR-UTILIZATION-NOT-FOUND (err u105))
(define-constant ERR-INVALID-INPUT (err u106))

;; ROLE DEFINITIONS

(define-constant ROLE-ADMIN u1)
(define-constant ROLE-MODERATOR u2)
(define-constant ROLE-BENEFICIARY u3)

;; DATA STRUCTURES

;; User permission matrix - Bitcoin-secured access control
(define-map roles
  { user: principal }
  { role: uint }
)

;; Beneficiary registry - verified impact recipients
(define-map beneficiaries
  { id: uint }
  {
    name: (string-utf8 50),
    description: (string-utf8 255),
    target-amount: uint,
    received-amount: uint,
    status: (string-ascii 20),
  }
)

;; Immutable donation ledger - cryptographic giving history
(define-map donations
  { id: uint }
  {
    donor: principal,
    beneficiary-id: uint,
    amount: uint,
    timestamp: uint,
  }
)

;; Milestone achievement tracker - verified impact progression
(define-map utilization
  { id: uint }
  {
    beneficiary-id: uint,
    milestone: uint,
    description: (string-utf8 255),
    amount: uint,
    status: (string-ascii 20),
  }
)

;; STATE VARIABLES

;; Sequential identity counters - ensuring data integrity
(define-data-var beneficiary-count uint u0)
(define-data-var donation-count uint u0)
(define-data-var utilization-count uint u0)

;; HELPER FUNCTIONS

;; Permission validator - cryptographic role verification
(define-private (is-authorized
    (user principal)
    (required-role uint)
  )
  (let ((role-data (default-to { role: u0 } (map-get? roles { user: user }))))
    (>= (get role role-data) required-role)
  )
)

;; Milestone progression calculator - achievement tracking
(define-private (get-last-milestone (beneficiary-id uint))
  (var-get utilization-count)
)

;; ROLE MANAGEMENT

;; Grant user permissions - owner-exclusive authority
(define-public (set-role
    (user principal)
    (new-role uint)
  )
  (let ((existing-role (default-to u0 (get role (map-get? roles { user: user })))))
    (if (and
        (is-eq tx-sender (var-get contract-owner))
        (<= new-role ROLE-BENEFICIARY)
        (not (is-eq user tx-sender)) ;; Self-modification protection
        (or
          (is-eq new-role ROLE-ADMIN)
          (is-eq new-role ROLE-MODERATOR)
          (is-eq new-role ROLE-BENEFICIARY)
        )
      )
      (ok (map-set roles { user: user } { role: new-role }))
      ERR-NOT-AUTHORIZED
    )
  )
)

;; Revoke user permissions - secured removal process
(define-public (remove-role (user principal))
  (if (and
      (is-eq tx-sender (var-get contract-owner))
      (is-some (map-get? roles { user: user }))
      (not (is-eq user tx-sender)) ;; Self-removal protection
    )
    (ok (map-delete roles { user: user }))
    ERR-NOT-AUTHORIZED
  )
)

;; BENEFICIARY MANAGEMENT

;; Create verified beneficiary - curated impact registration
(define-public (register-beneficiary
    (name (string-utf8 50))
    (description (string-utf8 255))
    (target-amount uint)
  )
  (let ((beneficiary-id (+ (var-get beneficiary-count) u1)))
    (if (and
        (is-authorized tx-sender ROLE-MODERATOR)
        (> (len name) u0)
        (> (len description) u0)
        (> target-amount u0)
      )
      (begin
        (map-set beneficiaries { id: beneficiary-id } {
          name: name,
          description: description,
          target-amount: target-amount,
          received-amount: u0,
          status: "active",
        })
        (var-set beneficiary-count beneficiary-id)
        (ok beneficiary-id)
      )
      ERR-INVALID-INPUT
    )
  )
)