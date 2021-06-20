#lang typed/racket

(provide (struct-out video-summary)
         video-summary->string
         index+hash->video-summary)

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

(module+ test
  (require typed/rackunit)
  (define example (video-summary 12 "title" "channel" "date" "id"))
  (define example-hash (hash 'title "title" 'channel "channel" 'upload_date "date" 'id "id"))
  (test-case "video-summary->string"
    (check-equal? (video-summary->string example) "12  title  channel  date  id"))
  (test-case "index+hash->video-summary valid hash map"
    (check-equal? (index+hash->video-summary 12 example-hash) example))
  (test-case "index+hash->video-summary invalid hash map"
    (check-exn exn:fail? (λ () (index+hash->video-summary 12 (hash-set example-hash 'title 123)))))
  )
