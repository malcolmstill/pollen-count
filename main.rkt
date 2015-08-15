#lang racket

(require txexpr
	 racket/list
	 racket/string
	 racket/match
	 racket/function
	 (for-syntax racket/syntax))

(provide Alpha
	 alpha
	 define-countable-tag
	 reset-counter
	 cross-reference)

(define (Alpha i)
  (string (integer->char (+ 64 i))))

(define (alpha i)
  (string (integer->char (+ 96 i))))

(define (make-counter initial render [parent #f] [separator "."])
  (define count initial)
  (define prev-parent-count (if parent (parent 'count) #f))
  (λ (action)
    (when (and parent (not (= (parent 'count) prev-parent-count)))
      (set! prev-parent-count (parent 'count))
      (set! count initial))
    (match action
      ['count count]
      ['reset (set! count initial)]
      ['increment (set! count (+ count 1))]
      ['to-string (if parent
		      (string-append (parent 'to-string) separator (render count))
		      (render count))])))

(define-syntax (reset-counter stx)
  (syntax-case stx ()
    [(_ tagname)
     (with-syntax ([tag-counter (format-id stx "~a-counter" #'tagname)])
       #'(tag-counter 'reset))]))

(define label-map (hash))
(define (clear-labelling)
  (set! label-map (hash)))
(define (update-label-map label number)
  (set! label-map (hash-set label-map label number)))

(define-syntax (define-countable-tag stx)
  (syntax-case stx ()
    [(_ (tagname a ... . rest) (initial render parent-tagname separator) (count) proc ...)
     (with-syntax ([tag-counter (format-id stx "~a-counter" #'tagname)]
                   [parent-counter (if (symbol? (syntax->datum #'parent-tagname))
                                       (format-id stx "~a-counter" #'parent-tagname)
                                       #'parent-tagname)])
       #'(begin
           (define tag-counter (make-counter initial render parent-counter separator))
           (define (tagname #:label [label #f] a ... . rest)
             (tag-counter 'increment)
             (define count (tag-counter 'to-string))
             (if label
                 (begin
                   (update-label-map label count)
                   (attr-set proc ... 'id label))
                 proc ...))))]))

(define (cross-reference doc)
  (define-values (d _)
    (splitf-txexpr doc
                   (λ (x)
                     (and (txexpr? x)
			  (member (car x) '(ref hyperref))))
                   (λ (x)
		     (match x
		       [(list 'hyperref text ref) `(a ((href ,(string-append "#" ref)))
						      ,text ,(hash-ref label-map ref))]
		       [(list 'hyperref ref) `(a ((href ,(string-append "#" ref)))
						 ,(hash-ref label-map ref))]
		       [(list 'ref ref) (hash-ref label-map ref)]))))
  (clear-labelling)
  d)
