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