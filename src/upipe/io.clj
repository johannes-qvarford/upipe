(ns upipe.io
    (:import [java.io StringWriter])
    (:require [clojure.pprint :as pp])
    (:require [clojure.java.io :as jio]))

(defn write-file [file object]
    (binding [*out* (new StringWriter)]
        (pp/write object)
        (spit file (str *out*))))

(defn read-file [file]
    (when (.exists (jio/as-file file))
        (read-string (slurp file))))