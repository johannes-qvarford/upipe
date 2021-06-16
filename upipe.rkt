#lang racket

(require json)
(require racket/function)
(require racket/port)

(define (title) "(title)")
(define (ext) "(ext)")
(define *data-directory* (make-parameter "data"))
(define (archive-directory) (format "~a/~a" (*data-directory*) "ytdl-archive.txt"))
(define url "https://www.youtube.com/c/ChorpSawaySA/videos")
(define (date-too-early) "today-2weeks")
(define (videos-to-check) 5)

(define (video-output-path-format channel)
  (format "~a/~a/%(title)s.%(ext)s" (*data-directory*) channel))

(define (channel-latest-yt-videos-port name url)
  (define output-string
    (with-output-to-string
      (λ () (system* 
                     "/usr/local/bin/youtube-dl"
                     "--dateafter" (date-too-early)
                     "--playlist-end" (number->string (videos-to-check))
                     "--download-archive" (archive-directory)
                     "--dump-json"
                     "-o" (video-output-path-format name)
                     url))))
  (open-input-string output-string))

(define (json-stream json-port)
  (define jsexpr (read-json json-port))
  (if (eof-object? jsexpr) empty-stream
      (stream-cons jsexpr (json-stream json-port))))

(define (yt-video-summaries seq)
  (for/list ([i (in-naturals)] [jsexpr seq])
    (yt-video-summary i jsexpr)))

(define (yt-video-summary index jsexpr)
  (let*
      ([get (curry hash-ref jsexpr)])
    (format "~a  ~a  ~a  ~a  ~a" index (get 'title) (get 'channel) (get 'upload_date) (get 'id))))

(define (latest-videos-command)
  (define json-port (channel-latest-yt-videos-port "Chorpsaway" url))
  (define summaries (yt-video-summaries (json-stream json-port)))
  (for ([s summaries])
    (display s)
    (display #\newline)))

(latest-videos-command)

; Goals:
; Fetch from list of subscriptions ("name" "url")
; Store subscriptions in file, and read them when fetching latest videos.
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
