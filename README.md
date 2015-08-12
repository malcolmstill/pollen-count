pollen-count
============

Example usage in directory-require.rkt:

(define section-counter (make-counter 0 number->string))
(define subsection-counter (make-counter 0 number->string section-counter))
(define subsubsection-counter (make-counter 0 number->string subsection-counter))
(define figure-counter (make-counter 0 Alpha section-counter))

(define tag-counters (hash 'section section-counter
                           'subsection subsection-counter
                           'subsubsection subsubsection-counter
                           'figure figure-counter))

(number-and-xref tag-counters doc)
