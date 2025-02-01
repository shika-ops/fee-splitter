;; File: contracts/fee-splitter.clar

(define-constant ERR_INVALID_PERCENTAGE (err u100)) ;; Error: Percentages must sum to 100.
(define-constant ERR_NOT_AUTHORIZED (err u101)) ;; Error: Only the contract deployer can update recipients.

(define-data-var contract-owner principal tx-sender)
(define-data-var recipients (list 10 (tuple (address principal) (share uint))) (list)) ;; Maximum 10 recipients.

;; Initialize the contract with an empty recipient list.
(define-public (initialize-recipients (new-recipients (list 10 (tuple (address principal) (share uint)))))
    (begin
        ;; Only the contract deployer can initialize recipients.
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
        
        ;; Validate that the total percentage is 100.
        (asserts! (is-eq (calculate-total-share new-recipients) u100) ERR_INVALID_PERCENTAGE)

        ;; Update the recipients data variable.
        (ok (var-set recipients new-recipients))
    )
)

;; Handle the splitting of payments.
(define-public (split-payment)
    (let ((total-stx (stx-get-balance tx-sender)) ;; Get the total STX balance of the sender.
         (recipients-list (var-get recipients))) ;; Get the current list of recipients.
        ;; Ensure there are recipients set up.
        (asserts! (> (len recipients-list) u0) (err u102))

        ;; Use fold to iterate over recipients and distribute funds proportionally.
        (ok (fold transfer-to-recipient
            recipients-list
            total-stx))
    )
)

;; Helper function to transfer STX to a recipient
(define-private (transfer-to-recipient 
    (recipient (tuple (address principal) (share uint))) 
    (remaining-stx uint))
    (let (
        (recipient-address (get address recipient))
        (recipient-share (get share recipient))
        (amount (/ (* remaining-stx recipient-share) u100))
    )
        (if (> amount u0)
            (match (stx-transfer? amount tx-sender recipient-address)
                success (- remaining-stx amount)
                error remaining-stx)
            remaining-stx)
    )
)



;; Helper function to sum shares
(define-private (sum-shares (recipient (tuple (address principal) (share uint))) (sum uint))
    (+ sum (get share recipient))
)

;; Calculate the total share to ensure it equals 100.
(define-read-only (calculate-total-share (recipient-list (list 10 (tuple (address principal) (share uint)))))
    (fold sum-shares
        recipient-list
        u0
    )
)
