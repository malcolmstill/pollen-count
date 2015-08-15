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

These tags can then be used in .pms as follows:
```
#lang pollen

◊section[#:label "sec:intro"]{Introduction}

The ship's all yours. If the scanners pick up anything, report it immediately.
All right, let's go. Hey down there, could you give us a hand with this?
TX-four-one-two. Why aren't you at your post? TX-four-one-two, do you copy?
Take over. We've got a bad transmitter. I'll see what I can do. You know,
between his howling and your blasting everything in sight, it's a wonder the
whole station doesn't know we're here. Bring them on! I prefer a straight
fight to all this sneaking around. We found the computer outlet, sir. Plug in.
He should be able to interpret the entire Imperial computer network.

◊section[]{Star Wars VII}

As per ◊hyperref["Section "]{sec:intro} all troop carriers will assemble at
the north entrance. The heavy transport ships will leave as soon as they're
loaded. Only two fighter escorts per ship. The energy shield can only be
opened for a short time, so you'll have to stay very close to your transports.
Two fighters against a Star Destroyer? The ion cannon will fire several shots
to make sure that any enemy ships will be out of your flight path. When
you've gotten past the energy shield, proceed directly to the rendezvous
point. Understood? Right. Okay. Good luck. Okay. Everyone to your stations.
Let's go!◊sup{◊hyperref{foot:c3po}}

◊section{Footnotes}

◊footnote[#:label "foot:c3po"]{No, Threepio's with them. Just hang on.
We're almost there. Mmmm. Oh, my. Uh, I, uh - Take this off! I, uh, don't
mean to intrude here. I, don't, no, no, no...Please don't get up. No!
Stormtroopers? Here? We're in danger. I must tell the others. Oh, no!
I've been shot!}

```
