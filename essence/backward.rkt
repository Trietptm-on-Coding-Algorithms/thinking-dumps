#lang racket
;; Backward state in impure langugage as a partice

;; Haskell version: see 'backward.hs'
;;

; (require racket/match)


;; monad functions
(define (monad ret bnd)
  (cons ret bnd))
(define (return monad)
  (car monad))
(define (bind monad)
  (cdr monad))

(define (sequence monad ms)
  (define bnd (bind monad))
  (define ret (return monad))

  (match ms
    ['() ((return monad) '())]
    [(cons mv mxs)
     (mv . bnd .
         (λ (v)
           ((sequence monad mxs) . bnd .
            (λ (vs)
              (ret (cons v vs))))
           ))]))


;; monad for testing
(define (just x) (cons 'just x))
(define (nothing) (cons 'nothing '()))
(define (bindMaybe m k)
  (if (eq? (car m) 'just)
      (k (cdr m))
      m))
(define maybe (monad just bindMaybe))


;; normal state
(define (returnN x)
  (λ (s) (cons x s)))
(define (bindN m k)
  (λ (s0)
    (match (m s0)
      [(cons a s1)
       ((k a) s1)])))

(define nstate (monad returnN bindN))


;; backward state
(define (returnB x)
  (λ (s) (cons (λ () x)
               (λ () s))))

;;   m >>= k  = BState $ \s'' -> let (a, s)  = runBState m s'
;;                                   (b, s') = runBState (k a) s''
;;                               in (b, s)

(define (bindB m k)
  (λ (s2)
    (define (valgen st) (car (m st)))
    (define (stgen  st) (cdr (m st)))

    (match-define (cons b s1)
                  ((k ((valgen '()))) s2)
      )
    (let ([new-state (calc-state m)]
          [new-value (calc-value m)])
      (cons new-state new-value))))

(define bstate (monad returnB bindB))


;; commons
(define (exec-state monad m si)
  (cdr (m si)))
(define (exec-states monad ms si)
  (cdr ((sequence monad ms) si)))

;; update-state :: (s -> s) -> (s -> ((), s))
(define (update-state f)
  (λ (s) (cons '() (f s))))


;; sample actions
(define puta (update-state (λ (x) (string-append x "a"))))
(define putb (update-state (λ (x) (string-append x "b"))))

(define program
  (list puta
        putb
        putb))


;; main

;; for testing monad
; (printf "~a\n" (sequence maybe (list (just 1) (just 2))))

;; should output "abb"
(printf "~a\n" (exec-states nstate program ""))
;; should output "bba"
(printf "~a\n" (exec-states bstate program ""))
