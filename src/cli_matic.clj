;; hack: bb doesn't have java.text.DateFormat, conversions are done using java.time
(ns java.text)
(defrecord SimpleDateFormat [])

(ns clojure.spec.gen.alpha)

(ns cli-matic
  (:require [babashka.deps :as deps]))

(deps/add-deps
 '{:deps {borkdude/spartan.spec {:git/url "https://github.com/borkdude/spartan.spec"
                                 :sha "bf4ace4a857c29cbcbb934f6a4035cfabe173ff1"}
          cli-matic/cli-matic {:mvn/version "0.4.3"}}})

(require 'spartan.spec) ;; creates clojure.spec.alpha

(binding [*err* (java.io.StringWriter.)]
  (require '[cli-matic.core :refer [run-cmd]]))

;; again, to satisfy clj-kondo...
(require '[cli-matic.core :refer [run-cmd]])