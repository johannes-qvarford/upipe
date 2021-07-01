(ns upipe.json
    (:require [cheshire.core :as json]))

(defn reader->seq [r]
    (map json/parse-string (line-seq r)))