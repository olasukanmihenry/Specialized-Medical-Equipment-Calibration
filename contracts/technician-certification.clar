;; Technician Certification Contract
;; Validates qualifications for calibration

;; Define data maps
(define-map technician-profiles
  { technician: principal }
  {
    name: (string-ascii 100),
    organization: (string-ascii 100),
    license-number: (string-ascii 50),
    license-expiry: uint,
    registration-time: uint,
    active: bool
  }
)

;; Define data maps for certifications
(define-map device-certifications
  { technician: principal, device-type: (string-ascii 100) }
  {
    certification-level: uint,
    issued-by: principal,
    issue-date: uint,
    expiry-date: uint,
    training-verification: (string-ascii 200)
  }
)

;; Define data maps for certification authorities
(define-map certification-authorities
  { authority: principal }
  {
    organization: (string-ascii 100),
    authorized-by: principal,
    authorization-time: uint,
    active: bool
  }
)

;; Error codes
(define-constant err-invalid-input u1)
(define-constant err-not-found u2)
(define-constant err-not-authorized u3)
(define-constant err-expired-license u4)

;; Read-only functions
(define-read-only (get-technician-profile (technician principal))
  (map-get? technician-profiles { technician: technician })
)

(define-read-only (get-device-certification (technician principal) (device-type (string-ascii 100)))
  (map-get? device-certifications { technician: technician, device-type: device-type })
)

(define-read-only (is-certification-authority (authority principal))
  (default-to false (get active (map-get? certification-authorities { authority: authority })))
)

(define-read-only (is-certified-for-device (technician principal) (device-type (string-ascii 100)))
  (let ((cert (map-get? device-certifications { technician: technician, device-type: device-type })))
    (and
      (is-some cert)
      (> (get expiry-date (default-to
        { certification-level: u0, issued-by: technician, issue-date: u0, expiry-date: u0, training-verification: "" }
        cert))
        block-height)
    )
  )
)

;; Public functions
(define-public (register-technician
    (name (string-ascii 100))
    (organization (string-ascii 100))
    (license-number (string-ascii 50))
    (license-expiry uint))

  (begin
    ;; Check inputs
    (asserts! (> (len name) u0) (err err-invalid-input))
    (asserts! (> (len organization) u0) (err err-invalid-input))
    (asserts! (> (len license-number) u0) (err err-invalid-input))
    (asserts! (> license-expiry block-height) (err err-expired-license))

    ;; Insert technician profile
    (map-set technician-profiles
      { technician: tx-sender }
      {
        name: name,
        organization: organization,
        license-number: license-number,
        license-expiry: license-expiry,
        registration-time: block-height,
        active: true
      }
    )

    ;; Return success
    (ok true)
  )
)

(define-public (update-technician-profile
    (name (string-ascii 100))
    (organization (string-ascii 100))
    (license-number (string-ascii 50))
    (license-expiry uint))

  (let ((profile (unwrap! (get-technician-profile tx-sender) (err err-not-found))))
    ;; Check inputs
    (asserts! (> (len name) u0) (err err-invalid-input))
    (asserts! (> (len organization) u0) (err err-invalid-input))
    (asserts! (> (len license-number) u0) (err err-invalid-input))
    (asserts! (> license-expiry block-height) (err err-expired-license))

    ;; Update profile
    (map-set technician-profiles
      { technician: tx-sender }
      {
        name: name,
        organization: organization,
        license-number: license-number,
        license-expiry: license-expiry,
        registration-time: (get registration-time profile),
        active: (get active profile)
      }
    )

    ;; Return success
    (ok true)
  )
)

(define-public (issue-device-certification
    (technician principal)
    (device-type (string-ascii 100))
    (certification-level uint)
    (expiry-date uint)
    (training-verification (string-ascii 200)))

  (begin
    ;; Check authorization
    (asserts! (is-certification-authority tx-sender) (err err-not-authorized))

    ;; Check technician exists
    (asserts! (is-some (get-technician-profile technician)) (err err-not-found))

    ;; Check inputs
    (asserts! (> (len device-type) u0) (err err-invalid-input))
    (asserts! (> certification-level u0) (err err-invalid-input))
    (asserts! (> expiry-date block-height) (err err-invalid-input))
    (asserts! (> (len training-verification) u0) (err err-invalid-input))

    ;; Issue certification
    (map-set device-certifications
      { technician: technician, device-type: device-type }
      {
        certification-level: certification-level,
        issued-by: tx-sender,
        issue-date: block-height,
        expiry-date: expiry-date,
        training-verification: training-verification
      }
    )

    ;; Return success
    (ok true)
  )
)

(define-public (register-certification-authority
    (organization (string-ascii 100)))

  (begin
    ;; Check inputs
    (asserts! (> (len organization) u0) (err err-invalid-input))

    ;; Register authority
    (map-set certification-authorities
      { authority: tx-sender }
      {
        organization: organization,
        authorized-by: tx-sender,
        authorization-time: block-height,
        active: true
      }
    )

    ;; Return success
    (ok true)
  )
)

