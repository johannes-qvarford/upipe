(ns upipe.subscription
    (:require [upipe.location :as loc])
    (:require [upipe.io :as uio]))

(def -identity-keys [:name :url])

(defn -subscriptions-path []
    (str loc/data-directory "/subscriptions.edn"))

;; public

(defn subscription? [sub]
    (every? #(contains? sub %1) -identity-keys))

(defn subscriptions? [subs]
    (every? subscription? subs))

(defn read-subscriptions []
    {:post ([subscriptions? %])}
    (uio/read-file (-subscriptions-path)))

(defn write-subscriptions [subs]
    {:pre ([subscriptions? subs])}
    (uio/write-file (-subscriptions-path) subs))