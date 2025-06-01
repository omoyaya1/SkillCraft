;; SkillCraft: Professional Tutorial and Knowledge Exchange Platform
;; Version: 1.0.0
(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-TUTORIAL-NOT-FOUND (err u2))
(define-constant ERR-ALREADY-PUBLISHED (err u3))
(define-constant ERR-INVALID-STATUS (err u4))
(define-constant ERR-INVALID-DURATION (err u5))
(define-constant ERR-INVALID-SKILL-CATEGORY (err u6))
(define-constant ERR-INVALID-EXPERTISE-LEVEL (err u7))
(define-constant ERR-INVALID-TUTORIAL-TITLE (err u8))
(define-constant ERR-INVALID-CONTENT (err u9))
(define-constant MIN-DURATION u5)
(define-data-var next-tutorial-id uint u1)
(define-map tutorial-library
    uint
    {
        instructor: principal,
        tutorial-title: (string-utf8 50),
        content: (string-utf8 200),
        skill-category: (string-utf8 15),
        expertise-level: (string-utf8 10),
        publication-status: (string-utf8 15),
        duration-minutes: uint
    }
)
(define-private (validate-skill-category (skill-category (string-utf8 15)))
    (or 
        (is-eq skill-category u"Programming")
        (is-eq skill-category u"Design")
        (is-eq skill-category u"Marketing")
        (is-eq skill-category u"Finance")
        (is-eq skill-category u"Crafts")
        (is-eq skill-category u"Music")
    )
)
(define-private (validate-expertise-level (expertise-level (string-utf8 10)))
    (or 
        (is-eq expertise-level u"Novice")
        (is-eq expertise-level u"Basic")
        (is-eq expertise-level u"Intermediate")
        (is-eq expertise-level u"Advanced")
        (is-eq expertise-level u"Master")
    )
)
(define-private (validate-text-quality (text (string-utf8 200)) (min-length uint) (max-length uint))
    (let 
        (
            (text-length (len text))
        )
        (and 
            (>= text-length min-length)
            (<= text-length max-length)
        )
    )
)
(define-public (publish-tutorial 
    (tutorial-title (string-utf8 50))
    (content (string-utf8 200))
    (skill-category (string-utf8 15))
    (expertise-level (string-utf8 10))
    (duration-minutes uint)
)
    (let
        (
            (tutorial-id (var-get next-tutorial-id))
        )
        (asserts! (validate-text-quality tutorial-title u3 u50) ERR-INVALID-TUTORIAL-TITLE)
        (asserts! (validate-text-quality content u10 u200) ERR-INVALID-CONTENT)
        (asserts! (>= duration-minutes MIN-DURATION) ERR-INVALID-DURATION)
        (asserts! (validate-skill-category skill-category) ERR-INVALID-SKILL-CATEGORY)
        (asserts! (validate-expertise-level expertise-level) ERR-INVALID-EXPERTISE-LEVEL)
        
        (map-set tutorial-library tutorial-id {
            instructor: tx-sender,
            tutorial-title: tutorial-title,
            content: content,
            skill-category: skill-category,
            expertise-level: expertise-level,
            publication-status: u"live",
            duration-minutes: duration-minutes
        })
        (var-set next-tutorial-id (+ tutorial-id u1))
        (ok tutorial-id)
    )
)
(define-public (archive-tutorial (tutorial-id uint))
    (let
        (
            (tutorial (unwrap! (map-get? tutorial-library tutorial-id) ERR-TUTORIAL-NOT-FOUND))
        )
        (asserts! (is-eq tx-sender (get instructor tutorial)) ERR-NOT-AUTHORIZED)
        (asserts! (is-eq (get publication-status tutorial) u"live") ERR-INVALID-STATUS)
        (ok (map-set tutorial-library tutorial-id (merge tutorial { publication-status: u"archived" })))
    )
)
(define-read-only (get-tutorial (tutorial-id uint))
    (ok (map-get? tutorial-library tutorial-id))
)
(define-read-only (get-instructor (tutorial-id uint))
    (ok (get instructor (unwrap! (map-get? tutorial-library tutorial-id) ERR-TUTORIAL-NOT-FOUND)))
)