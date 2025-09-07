;; title: Blockchain-Voting
;; version: 1.0.0
;; summary: Transparent town-hall voting system for local communities
;; description: A simple voting contract that allows communities to create proposals and vote transparently

;; constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-voted (err u102))
(define-constant err-voting-ended (err u103))
(define-constant err-voting-not-ended (err u104))

;; data vars
(define-data-var next-proposal-id uint u0)

;; data maps
(define-map proposals
  { proposal-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    proposer: principal,
    yes-votes: uint,
    no-votes: uint,
    end-height: uint,
    executed: bool
  }
)

(define-map votes
  { proposal-id: uint, voter: principal }
  { vote: bool }
)

;; public functions
(define-public (create-proposal (title (string-ascii 100)) (description (string-ascii 500)) (duration uint))
  (let
    (
      (proposal-id (var-get next-proposal-id))
      (end-height (+ block-height duration))
    )
    (map-set proposals
      { proposal-id: proposal-id }
      {
        title: title,
        description: description,
        proposer: tx-sender,
        yes-votes: u0,
        no-votes: u0,
        end-height: end-height,
        executed: false
      }
    )
    (var-set next-proposal-id (+ proposal-id u1))
    (ok proposal-id)
  )
)

(define-public (cast-vote (proposal-id uint) (vote bool))
  (let
    (
      (proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) err-not-found))
      (existing-vote (map-get? votes { proposal-id: proposal-id, voter: tx-sender }))
    )
    (asserts! (is-none existing-vote) err-already-voted)
    (asserts! (<= block-height (get end-height proposal)) err-voting-ended)

    (map-set votes
      { proposal-id: proposal-id, voter: tx-sender }
      { vote: vote }
    )

    (if vote
      (map-set proposals
        { proposal-id: proposal-id }
        (merge proposal { yes-votes: (+ (get yes-votes proposal) u1) })
      )
      (map-set proposals
        { proposal-id: proposal-id }
        (merge proposal { no-votes: (+ (get no-votes proposal) u1) })
      )
    )
    (ok true)
  )
)

;; read only functions
(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals { proposal-id: proposal-id })
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes { proposal-id: proposal-id, voter: voter })
)

(define-read-only (get-proposal-results (proposal-id uint))
  (match (map-get? proposals { proposal-id: proposal-id })
    proposal
    (ok {
      yes-votes: (get yes-votes proposal),
      no-votes: (get no-votes proposal),
      total-votes: (+ (get yes-votes proposal) (get no-votes proposal)),
      ended: (> block-height (get end-height proposal))
    })
    err-not-found
  )
)

(define-read-only (get-next-proposal-id)
  (var-get next-proposal-id)
)

