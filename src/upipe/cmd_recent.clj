(ns upipe.cmd-recent
    (:require [upipe.video-summary :as vs]
        [upipe.json :as json]
        [upipe.location :as loc]
        [upipe.subscription :as sub]
        [clojure.java.io :as io]
        [clojure.string :as string]
        [clojure.java.shell :as shell]
        [cheshire.core :as che]))

(defn -non-negative-integers
    ([] (-non-negative-integers 0))
    ([n] (lazy-seq (cons n (-non-negative-integers (inc n))))))

(defn -date-too-early [] "today-2weeks")
(defn -videos-to-check [] 5)
(defn -output-format [sub-name]
    (format "%s/subscriptions/%s/%%(title)s.%%(ext)s" loc/data-directory sub-name))
(defn -archive-path [] (str loc/data-directory "/ytdl-archive.txt"))
(defn -sh-arguments [sub]
    ["/usr/local/bin/youtube-dl"
    "--dateafter" (-date-too-early)
    "--playlist-end" (str (-videos-to-check))
    "--download-archive" (-archive-path)
    "--dump-json"
    "-o" (-output-format (:name sub))
    "--"
    (:url sub)])

(defn -recent-video-output [sq]
    (->> sq
        (map che/parse-string)
        (map vs/from-json-object)
        (map vs/with-index (-non-negative-integers))
        (map vs/->string)
        (string/join "\n")))

(defn -combine-subscription-readers [subs generate-reader]
    (as-> subs $
        (map -sh-arguments $)
        (map generate-reader $)
        (map line-seq $)
        (apply concat $)
        (-recent-video-output $)))

(defn -subscription-reader [sh-args]
    (let [res (apply shell/sh sh-args)]
        (binding [*out* *err*]
            (print (:err res)))
        (io/reader (char-array (:out res)))))

(defn run [args]
    (println (-combine-subscription-readers (sub/read-subscriptions) -subscription-reader)))