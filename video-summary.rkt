#lang typed/racket

(provide (struct-out video-summary)
         video-summary->string
         index+hash->video-summary
         save-latest-video-summaries
         latest-video-summaries)

(require racket/port
         "location.rkt")

(struct video-summary
  ([index : Integer]
   [title : String]
   [channel : String]
   [upload-date : String]
   [id : String])
  #:prefab)

(: video-summary->string : video-summary -> String)
(define (video-summary->string vs)
  (format "~a  ~a  ~a  ~a  ~a"
                   (video-summary-index vs)
                   (video-summary-title vs)
                   (video-summary-channel vs)
                   (video-summary-upload-date vs)
                   (video-summary-id vs)))

(: index+hash->video-summary : Integer HashTableTop -> video-summary)
(define (index+hash->video-summary index ht)
  (define (get symbol) (hash-ref ht symbol))
  (match (list (get 'title) (get 'channel) (get 'upload_date) (get 'id))
    [(list (? string? title)
          (? string? channel)
          (? string? upload-date)
          (? string? id))
     (video-summary index title channel upload-date id)]
    [else (error "Could not convert hash table to video-summary")]))

(define (latest-video-summaries)
  (call-with-input-file
   (latest-videos-path)
   (lambda ([port : Input-Port])
     (cast (port->list read-video-summary port) (Listof video-summary)))))

(define (save-latest-video-summaries vs)
  (with-output-to-file
    #:exists 'replace
    (latest-videos-path)
    (lambda ()
      (for ([v (in-list vs)])
        (write v)))))

(: read-video-summary : Input-Port -> (U EOF video-summary))
(define (read-video-summary port)
  (define input (read port))
  (match input
    [(video-summary (? exact-integer? index) (? string? title) (? string? channel) (? string? upload-date) (? string? id))
     (video-summary index title channel upload-date id)] 
    [(? eof-object?) eof]
    [else (error (format "Could not read video summary: ~s" input))]))

(: latest-videos-path : -> Path-String)
(define (latest-videos-path)
  (string->path (format "~a/~a" (data-directory) "latest-videos")))

(module+ test
  (require typed/rackunit)
  (define example (video-summary 12 "title" "channel" "date" "id"))
  (define example-hash (hash 'title "title" 'channel "channel" 'upload_date "date" 'id "id"))
  (test-case "video-summary->string"
    (check-equal? (video-summary->string example) "12  title  channel  date  id"))
  (test-case "index+hash->video-summary valid hash map"
    (check-equal? (index+hash->video-summary 12 example-hash) example))
  (test-case "index+hash->video-summary invalid hash map"
    (check-exn exn:fail? (λ () (index+hash->video-summary 12 (hash-set example-hash 'title 123))))))
