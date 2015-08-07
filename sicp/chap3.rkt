#lang racket

;; ex 3.1 make an accumulator
(define (make-accumulator n)
  (define x n)
  (λ (amount)
    (begin (set! x (+ x amount))
           x)))

;; ex 3.2 make function monitor wrapper
(define (make-monitored func)
  (define call-count 0)
  (λ xs (if (and (not (null? xs))
                 (= (length xs) 1)
                 (eq? 'how-many-calls? (car xs)))
            call-count
            (apply func xs))))


;; ex 3.3 account with password
#;
(define (make-account balance password)
  (define (withdraw amount)
    (if (>= balance amount)
        (set! balance (- balance amount))
        (error "insufficient balance")))
  (define (deposit amount)
    (set! balance (+ balance amount)))

  (define (password-correct? pwd) (eq? pwd password))

  (λ (password op)
    (if (password-correct? password)
        (cond [(eq? op 'withdraw) withdraw]
              [(eq? op 'deposit)  deposit])
        (error "wrong password!"))))


;; ex 3.4
(define (make-account balance password)
  (define (withdraw amount)
    (if (>= balance amount)
        (set! balance (- balance amount))
        (error "insufficient balance")))
  (define (deposit amount)
    (set! balance (+ balance amount)))
  (define mistake-count 0)

  (define (password-correct? pwd) (eq? pwd password))

  (λ (password op)
    (if (password-correct? password)
        (begin
          (set! mistake-count 0)
          (cond [(eq? op 'withdraw) withdraw]
                [(eq? op 'deposit)  deposit]))
        (begin
          (set! mistake-count (+ mistake-count 1))
          (if (> mistake-count 7)
              (error "☎︎110") ; or call-the-cops
              (error "wrong password!"))))))


;; ex 3.5 monte carlo integration
(define (monte-carlo trials experiment)
  (define (iter trials-remaining trials-passed)
    (cond ((= trials-remaining 0)
           (/ trials-passed trials))
          ((experiment)
           (iter (- trials-remaining 1) (+ trials-passed 1)))
          (else
           (iter (- trials-remaining 1) trials-passed))))
  (iter trials 0))

(define (random-in-range low high)
  (let ((range (- high low)))
    (+ low (* (random) range))))

(define (estimate-integral p x1 x2 y1 y2 trials)
  (define (new-p)
    (let ([x (random-in-range x1 x2)]
          [y (random-in-range y1 y2)])
      (p x y)))
  (monte-carlo trials new-p))

(define (estimated-pi radius trials)
  (define (in-circle? x y)
    (< (+ (expt x 2) (expt y 2))
       (expt radius 2)))

  (define ratio (estimate-integral in-circle?
                                   (- radius) radius
                                   (- radius) radius
                                   trials))
  ;; ratio = (pi * r^2) / (4 * r^2), pi = ratio * 4
  (exact->inexact (* ratio 4)))


;; ex 3.6 random with reset func
(define (make-rand seed)
  (define (rand op)
    (define (reset new-seed)
      (set! seed new-seed))
    (define (generate)
      ;; from microsoft random algorithm
      (set! seed (remainder (+ (* 214013 seed) 2531011) (expt 2 31)))
      seed)

    (cond [(eq? op 'reset) reset]
          [(eq? op 'generate) (generate)]))
  rand)


;; ex 3.7 make joint account
(define (make-joint-account acc password specific-password)
  (define (password-correct? pwd) (eq? pwd specific-password))
  (define (operate pwd operation)
    (if (password-correct? pwd)
        (acc password operation)
        (error "wrong password!")))
  operate)

;; ex 3.8 detect eval
(define (define-detector)
  (define val '())
  (define (func v)
    (if (null? val)
        (begin (set! val v) v)
        v))
  func)
(define f (define-detector))

;; f remember the first arg it was called with
;; and ignores those in all other calls


;; 3.9 show call tree

;; for clarity, i will use infix/s-expr mixed style

;; rec ver:
;;   (factorial 6)
;;   6 * (factorial 5)
;;   6 * 5 * (factorial 4)
;;   6 * 5 * 4 * (factorial 3)
;;   6 * 5 * 4 * 3 * (factorial 2)
;;   6 * 5 * 4 * 3 * 2 * (factorial 1)
;;   6 * 5 * 4 * 3 * 2 * 1
;;   6 * 5 * 4 * 3 * 2
;;   6 * 5 * 4 * 6
;;   6 * 5 * 24
;;   6 * 120
;;   720

;; iter ver:
;;   (factorial 6)
;;   (fact-iter 1 1 6)
;;   (fact-iter (1 * 1) (1 + 1) 6)
;;   (fact-iter (2 * 1) (2 + 1) 6)
;;   (fact-iter (3 * 2) (3 + 1) 6)
;;   (fact-iter (6 * 4) (4 + 1) 6)
;;   (fact-iter (24 * 5) (5 + 1) 6)
;;   (fact-iter (120 * 6) (6 + 1) 6)
;;   (fact-iter 720 7 6)
;;   720