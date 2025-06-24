;; Quality Manager Verification Contract
;; Manages authorized quality managers for aerospace components

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_EXISTS (err u101))
(define-constant ERR_NOT_FOUND (err u102))

;; Data Variables
(define-data-var contract-owner principal tx-sender)

;; Data Maps
(define-map quality-managers
  { manager: principal }
  {
    name: (string-ascii 50),
    certification-level: (string-ascii 20),
    authorized-by: principal,
    authorized-at: uint,
    active: bool
  }
)

;; Public Functions

;; Add a new quality manager
(define-public (add-quality-manager (manager principal) (name (string-ascii 50)) (certification-level (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (asserts! (is-none (map-get? quality-managers { manager: manager })) ERR_ALREADY_EXISTS)
    (ok (map-set quality-managers
      { manager: manager }
      {
        name: name,
        certification-level: certification-level,
        authorized-by: tx-sender,
        authorized-at: block-height,
        active: true
      }
    ))
  )
)

;; Deactivate a quality manager
(define-public (deactivate-manager (manager principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (match (map-get? quality-managers { manager: manager })
      manager-data (ok (map-set quality-managers
        { manager: manager }
        (merge manager-data { active: false })
      ))
      ERR_NOT_FOUND
    )
  )
)

;; Read-only Functions

;; Check if a manager is authorized and active
(define-read-only (is-authorized-manager (manager principal))
  (match (map-get? quality-managers { manager: manager })
    manager-data (get active manager-data)
    false
  )
)

;; Get manager details
(define-read-only (get-manager-details (manager principal))
  (map-get? quality-managers { manager: manager })
)
