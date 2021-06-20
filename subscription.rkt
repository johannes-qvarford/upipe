#lang typed/racket

(require "location.rkt")

(provide (struct-out subscription)
         subscriptions)

; Later:
; (push-subscription subscription)

(struct subscription (
                      [name : String]
                      [url : String])
  #:prefab)

(: subscriptions : -> (Listof subscription))
(define (subscriptions)
  (call-with-input-file (subscriptions-path)
    (λ ([port : Input-Port]) (cast (port->list read-subscription port) (Listof subscription)))))

(: read-subscription : Input-Port -> (U EOF subscription))
(define (read-subscription port)
  (define input (read port))
  (match input
    [(list (? string? name) (? string? url))
     (subscription name url)]
    [(? eof-object?) eof]
    [else (error (format "Could not read subscription: ~s" input))]))

(: subscriptions-path : -> Path-String)
(define (subscriptions-path)
  (string->path (format "~a/~a" (data-directory) "subscriptions")))

(module+ test
  (require typed/rackunit)
  (: with-string :
     (All () (
              (Listof (List String String))
              (-> (Listof subscription))
              -> (Listof subscription))))
  (define (with-string lst thnk)
    (define temporary-directory
      (string->path (string-append "/tmp/"  (number->string (random 1000000000)))))
    (make-directory temporary-directory)
    (parameterize ([data-directory temporary-directory])
      (with-output-to-file (subscriptions-path)
        (λ () (write-string (write/list lst))))
      (thnk)))
  (: write/list : (Listof Any) -> String)
  (define (write/list xs)
    (with-output-to-string
      (λ () (for ([x xs]) (write x)))))
  (define-syntax (with stx)
    (syntax-case stx ()
      [(_ lst body)
       #'(with-string lst (λ () body))]))
  (test-case "empty subscriptions"
    (check-equal? (with '() (subscriptions)) '()))
  (test-case "single subscription"
    (check-equal? (with '(("Sub1" "url")) (subscriptions))
                  (list (subscription "Sub1" "url"))))
  (test-case "multiple subscriptions"
    (check-equal? (with '(("Sub2" "url2") ("Sub3" "url3"))
                        (subscriptions))
                  (list
                   (subscription "Sub2" "url2")
                   (subscription "Sub3" "url3")))))

