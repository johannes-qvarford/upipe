#lang racket

(require json)
(require racket/function)
(require racket/port)

(define (title) "(title)")
(define (ext) "(ext)")

(define (yt-video-summary index json-port)
  (let* ([jsexpr (read-json json-port)]
         [get (curry hash-ref jsexpr)])
    (if (eof-object? jsexpr) #f
        (format "~a\t~a\t~a\t~a" index (get 'title) (get 'channel) (get 'id)))))

(define url "https://youtube.com/watch?v=M6EOBjxXUEM")

(define *data-directory* (make-parameter "data"))

(define (archive-directory) (format "~a/~a" (*data-directory*) "ytdl-archive.txt"))

(define (video-output-path-format channel)
  (format "~a/~a/%(title)s.%(ext)s" (*data-directory*) channel))

(define (date-too-early) "today-2months")

(define (channel-latest-yt-videos-port name url)
  (define output-string
    (with-output-to-string
      (λ () (system* 
                     "/usr/local/bin/youtube-dl"
                     "--dateafter" (date-too-early)
                     "--download-archive" (archive-directory)
                     "--dump-json"
                     "-o" (video-output-path-format name)
                     url))))
  (open-input-string output-string))

(display (yt-video-summary 0 (channel-latest-yt-videos-port "Chorpsaway" url)))

; Goals:
; Get today and yesterday's videos from channel
; Download files given indexes. Load indexes from file overwritten by previous check.
; Get today and yesterday's videos from channel-file (subscriptions).
; Write down latest "check date" when calling "upipe done". This will be the lowest date, with no upper-date.
; downloaded files are added to watchlist
; vlc playlist kept up-to-date with watchlist
; pop from watchlist
; clear watchlist
; sort watchlist
; Create a web server. Search for video id on home page and redirect to page with above information.

; Do the same, but for channel (channel:blabla).  

; Let us share the download archive between subscriptions.
; youtube-dl -s --max-downloads 2 https://www.youtube.com/channel/UCHu17oT5IL8uXt8WXQ2E-rQ
; youtube-dl --max-downloads 1 --download-archive ytdl-archive.txt -o "Chorpsaway/%(title)s.%(ext)s" $video_url
; 

;youtube-dl --newline -i --hls-prefer-native -o "Chorpsaway/%(title)s.%(ext)s" --write-description --write-info-json --write-annotations --cookies cookies.txt --write-thumbnail --dump-json --download-archive Chorpsaway/ytdl-archive.txt https://www.youtube.com/channel/UCHu17oT5IL8uXt8WXQ2E-rQ
