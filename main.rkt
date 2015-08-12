#lang racket

(require txexpr
	 racket/list
	 racket/string
	 racket/match
	 racket/function)

(provide Alpha
	 alpha
	 make-counter
	 enumerate
	 cross-reference
	 number-and-xref
	 gather-labels)

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

(define (enumerate tag-counters doc)
  (define-values (n _)
    (splitf-txexpr doc
		   (λ (x)
		     (and (txexpr? x)
			  (member (car x) (hash-keys tag-counters))))
		   (λ (x)
		     (let [(counter (hash-ref tag-counters (car x)))]
		       (counter 'increment)
		       (attr-set x 'data-number (counter 'to-string))))))
  n)

(define (gather-labels doc)
  (define label-map (make-hash))
  (define-values (doc-labeled all-labeled)
    (splitf-txexpr doc
		   (λ (x)
		     (and (txexpr? x)
			  (ormap (λ (y)
				   (if (txexpr? y)
				       (equal? (car y) 'label)
				       #f)) 
				 (get-elements x))))
		   (λ (x)
		     (filter (λ (el)
			       (not (and (list? el)
					 (equal? (car el) 'label))))
			     (attr-set x 'id (cadr (last (filter (λ (x)
								   (and (list? x) (equal? (car x) 'label)))
								 x))))))))
  (values doc-labeled
	  (make-immutable-hash (map (λ (labeled)
				      (cons 
				       (cadr (last (filter (λ (x)
							     (and (list? x) (equal? (car x) 'label)))
							   labeled)))
				       labeled)) all-labeled))))

(define (cross-reference doc label-map)
  (define-values (d _)
    (splitf-txexpr doc
		   (λ (x)
		     (and (txexpr? x)
			  (member (car x) '(ref hyperref))))
		   (λ (x)
		     (match x
		       [(list 'hyperref text ref) `(a ((href ,(string-append "#" ref)))
						      ,text ,(attr-ref (hash-ref label-map ref) 'data-number))]
		       [(list 'hyperref ref) `(a ((href ,(string-append "#" ref)))
						 ,(attr-ref (hash-ref label-map ref) 'data-number))]
		       [(list 'ref ref)  (attr-ref (hash-ref label-map ref) 'data-number)]))))
  d)

(define (number-and-xref tag-counters doc)
  (define numbered (enumerate tag-counters doc))
  (define-values (d label-map)
    (gather-labels numbered))
  (cross-reference d label-map))
