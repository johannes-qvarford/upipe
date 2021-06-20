#lang typed/racket

(provide
 data-directory)

(define data-directory (make-parameter (string->path "data")))
