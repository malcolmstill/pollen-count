#lang info
(define collection "pollen-count")
(define deps '("base"
               "rackunit-lib"
	       "txexpr"))
(define build-deps '("scribble-lib" "racket-doc"))
(define scribblings '(("scribblings/pollen-count.scrbl" ())))
(define pkg-desc "Counters and cross-referencing for use with pollen")
(define version "0.1")
(define pkg-authors '(mstill))
