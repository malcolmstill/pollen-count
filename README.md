pollen-count
============

Installation
------------
Installation at the command line:

```
raco pkg install pollen-count
```

Usage (typical)
---------------

In `directory-require.rkt`:
```
(require pollen-count)
```

Elsewhere in `directory-require.rtk` define some tags:
```
(define-countable-tag (section . xs) (0 number->string #f ".") (count)
  `(h2 ((id ,(symbol->string (gensym)))) ,count ". " ,@xs))

(define-countable-tag (subsection . xs) (0 number->string section ".") (count)
  `(h3 ((id ,(symbol->string (gensym)))) ,count ". " ,@xs))

(define-countable-tag (subsubsection . xs) (0 number->string subsection ".") (count)
  `(h4 ((id ,(symbol->string (gensym)))) ,count ". " ,@xs))

(define-countable-tag (footnote . xs) (0 number->string #f ".") (count)
  `(p ((class "footnote")) ,count ". " ,@xs))

(define-countable-tag (figure src #:width [width "90%"] . xs) (0 number->string #f ".") (count)
  `(figure
    (img ((width ,width) (src ,src)))
    (figcaption ,count ": " ,@xs)))

(define-countable-tag (listing lang cap . xs) (0 number->string #f ".") (count)
  `(figure ((class "listing"))
    ,(apply highlight lang xs)
```

In the `root` function within `directory-require.rkt` reset counters and call `cross-reference` on document `txexpr`:

```
(define (root . xs)
	...
	(reset-counter section)
	(reset-counter subsection)
	(reset-counter subsubsection)
	(reset-counter figure)
	(reset-counter listing)
	(reset-counter footnote)

	...
	(cross-reference `(doc ,@xs))
	...
	)

```
