#lang typed/racket

(require typed/json
         "subscription.rkt"
         "location.rkt"
         "video-summary.rkt")

(provide latest-videos-command)

(define (archive-path) (format "~a/~a" (data-directory) "ytdl-archive.txt"))
(define (date-too-early) "today-2weeks")
(define (videos-to-check) 5)

(define (video-output-path-format channel)
  (format "~a/~a/%(title)s.%(ext)s" (data-directory) channel))

(: subscription-latest-videos-port : String String -> Input-Port)
(define (subscription-latest-videos-port name url)
  (define output-string
    (with-output-to-string
      (λ () (system* 
                     "/usr/local/bin/youtube-dl"
                     "--dateafter" (date-too-early)
                     "--playlist-end" (number->string (videos-to-check))
                     "--download-archive" (archive-path)
                     "--dump-json"
                     "-o" (video-output-path-format name)
                     url))))
  (open-input-string output-string))

(: json-stream : Input-Port -> (Sequenceof HashTableTop))
(define (json-stream json-port)
  (define (read-jsexpr [port : Input-Port])
    (define jsexpr (read-json port))
    (match jsexpr
      [(? eof-object?) eof]
      [(? hash?) jsexpr]
      [else (error "Unexpected json expression")]))
  (in-port read-jsexpr json-port))

(: hash-seq->video-summaries : (Sequenceof HashTableTop) -> (Listof video-summary))
(define (hash-seq->video-summaries seq)
  (for/list ([i (in-naturals)] [jsexpr seq])
    (index+hash->video-summary i jsexpr)))

(: subscription-hash-seq : subscription -> (Sequenceof HashTableTop))
(define (subscription-hash-seq sub)
  (define json-port (subscription-latest-videos-port (subscription-name sub) (subscription-url sub)))
  (json-stream json-port))

(define (latest-videos-command)
  (define seqs
    (for/list: : (Listof (Sequenceof HashTableTop)) ([sub (in-list (subscriptions))])
      (subscription-hash-seq sub)))
  (define vs (hash-seq->video-summaries (apply sequence-append seqs)))
  (for ([s vs])
    (display (video-summary->string s))
    (display #\newline))
  (save-latest-video-summaries vs))

(module+ main
  (latest-videos-command))

; Goals:
; Download files given indexes. Load indexes from file overwritten by previous check.
; Get today and yesterday's videos from channel-file (subscriptions).
; Write down latest "check date" when calling "upipe done". This will be the lowest date, with no upper-date.
; downloaded files are added to watchlist
; vlc playlist kept up-to-date with watchlist
; pop from watchlist
; clear watchlist
; sort watchlist
; Increase video amount window if we're able to fetch all of them.
; Create a web server. Search for video id on home page and redirect to page with above information.

; Do the same, but for channel (channel:blabla).  

; Let us share the download archive between subscriptions.
; youtube-dl -s --max-downloads 2 https://www.youtube.com/channel/UCHu17oT5IL8uXt8WXQ2E-rQ
; youtube-dl --max-downloads 1 --download-archive ytdl-archive.txt -o "Chorpsaway/%(title)s.%(ext)s" $video_url
; 

;youtube-dl --newline -i --hls-prefer-native -o "Chorpsaway/%(title)s.%(ext)s" --write-description --write-info-json --write-annotations --cookies cookies.txt --write-thumbnail --dump-json --download-archive Chorpsaway/ytdl-archive.txt https://www.youtube.com/channel/UCHu17oT5IL8uXt8WXQ2E-rQ
