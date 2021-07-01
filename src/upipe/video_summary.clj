(ns upipe.video-summary
    (:require [clojure.string :as string])
    (:require [upipe.location :as loc])
    (:require [cheshire.core :as json2])
    (:require [upipe.io :as uio])
    (:import [java.io StringReader StringWriter]))

(def -identity-keys [:title :channel :upload-date :id])
(def -presentation-keys [:index :title :channel :upload-date :id])
(def -json-kws [:title :channel :upload-date :id])

(defn -kw->str [kw]
    (-> (str kw)
        (string/replace "-" "_")
        (string/replace ":" "")))

(defn -latest-path []
    (str loc/data-directory "/latest-videos.edn"))

;; public

(defn video-summary? [vs]
     (and
        (= (class vs) clojure.lang.PersistentArrayMap)
        (every? #(contains? vs %1) -identity-keys)))

(defn video-summary-json? [vs]
    (every? #(contains? vs %1) (map -kw->str -json-kws)))

(defn video-summaries? [vss]
    (every? video-summary? vss))

(defn ->string [vs]
    {:pre [(video-summary? vs)] :post [(string? %)]}
    (as-> vs $
        (map $ -presentation-keys)
        (string/join "  " $)))

(defn with-index [index vs]
    {:pre [(video-summary? vs)] :post [(video-summary? %)]}
    (assoc vs :index index))

(defn read-latest []
    {:post [(video-summaries? %)]}
    (uio/read-file (-latest-path)))

(defn write-latest [vss]
    {:pre [(video-summaries? vss)]}
    (uio/write-file (-latest-path) vss))

(defn from-json-object [j]
    {:pre [(video-summary-json? j)] :post [(video-summary? %)]}
    (reduce #(conj %1 [%2 (j (-kw->str %2))]) {} -json-kws))

(defn from-json-object2 [j]
    {:pre [(video-summary-json? j)] :post [(video-summary? %)]}
    (reduce #(cons (j (-kw->str %2)) %1) {} -json-kws))
    