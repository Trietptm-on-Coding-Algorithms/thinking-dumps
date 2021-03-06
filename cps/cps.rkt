#lang racket

(require racket/match)
(require racket/pretty)

(define (atom? x)
  (or (integer? x) (symbol? x)))


;; compile cps directly
(define (compile-cps p k)
  (match p
    [(? atom?) `(,k ,p)]

    [`(if ,condition ,if-part ,else-part)
     (let ([bool-var (gensym 'b)]
           [if-part-cps (compile-cps if-part k)]
           [else-part-cps (compile-cps else-part k)])
       (compile-cps condition
                    `(λ (,bool-var)
                       (if ,bool-var
                           ,if-part-cps
                           ,else-part-cps))))]

    [`(begin ,expressions ...)
     (let* ([expr-symbols (map (λ (_) (gensym 'e)) expressions)]
            [last-symbol (last expr-symbols)]
            [procedure (λ (data accum)
                         (let ([expr (car data)]
                               [name (cadr data)])
                           (compile-cps
                            expr
                            `(λ (,name) ,accum))))]
            [data-list (zip expressions expr-symbols)])
       (foldr procedure `(,k ,last-symbol) data-list))]

    [`(λ (,parameters ...) ,body)
     (let* ([lambda-k (gensym 'k)]
            [body-cps (compile-cps body lambda-k)])
       `(,k (λ (,@parameters ,lambda-k)
              ,body-cps)))]

    [`(,operator ,operands ...)
     #:when (symbol? operator)

     (let* ([operand-symbols (map (λ (_) (gensym 'a)) operands)]
            [last-symbol (last operand-symbols)]
            [procedure (λ (data accum)
                         (let ([expr (car data)]
                               [name (cadr data)])
                           (compile-cps expr
                                        `(λ (,name) ,accum))))]
            [operator-cps-name (string->symbol
                                (format "~a&" operator))]
            [data-list (zip operands operand-symbols)]
            [base-expr-cps `(,operator-cps-name ,@operand-symbols ,k)]
            )
       (foldr procedure base-expr-cps data-list))]


    [`(,operator ,operands ...)
     (let* ([operand-symbols (map (λ (_) (gensym 'a)) operands)]
            [last-symbol (last operand-symbols)]
            [procedure (λ (data accum)
                         (let ([expr (car data)]
                               [name (cdr data)])
                           (compile-cps expr
                                        `(λ (,name) ,accum))))]
            [operator-name (gensym 'f)]
            [data-list (zip operands operand-symbols)]
            [base-expr-cps `(,operator-name ,@operand-symbols ,k)]
            [operands-cps (foldr procedure base-expr-cps data-list)])
       (compile-cps operator `(λ (,operator-name) ,operands-cps)))]

    ))


(define (optimize p)
  (match p
    [val #:when (atom? val)
         val]

    [`((λ (,params ...) ,body) ,args ...)
     (optimize `(let (,@(zip params (map optimize args)))
                  ,(optimize body)))]

    [`(let (,a ...) (let (,b ...) ,body))
     (optimize `(let (,@a ,@b) ,body))]

    [`(λ (,params ...) ,body)
     `(λ (,@params) ,(optimize body))]

    [`(,f ,x ...)
     `(,(optimize f) ,@(map optimize x))]

    ))

(define (zip l1 l2)
  (match* (l1 l2)
    [(`(,x ,xs ...) `(,y ,ys ...))
     (cons (list x y)
           (zip xs ys))]
    [(_ _) '()]))


(define example-program-1
  '(+ 2 1))
(define example-program-2
  '(print (+ 2 1)))
(define example-program-3
  '((λ (x) (print (+ x 1))) 2))
(define example-program-4
  '((λ (x) (if (x < 10)
               (print (+ x 1))
               (print (+ x 2))))
    12))

(define env
  '(
    [k (λ (x) x)]
    [print& (λ (x k) (k (println x)))]
    [+& (λ (x y k) (k (+ x y)))]
    ))

(let* ([program '(+ 2 (+ 3 4))]
       [program-cps (compile-cps program 'k)]
       [eval-expr `(let ,env ,program-cps)])
  (printf "Program\n\t~a\n" program)
  (printf "Compiled Program\n~a\n"
          (pretty-format program-cps 40))
  (printf "Optimized Program\n~a\n"
          (pretty-format (optimize program-cps) 40))
  (printf "Evaluated Result\n\t")
  (printf "~a\n" (eval eval-expr))
  )


;; (print
;;  (compile-cps
;;   '(if (1 < 2) (begin 3 4) 5)
;;   'k)
;;  )
