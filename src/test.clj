(ns test
    (:require cli-matic [cli-matic.core :refer [run-cmd]]))

(defn add_numbers
    "Sums A and B together, and prints it in base `base`"
    [{:keys [a b base]}]
    (println
     (Integer/toString (+ a b) base)))
  
  (defn subtract_numbers
    "Subtracts B from A, and prints it in base `base` "
    [{:keys [a b base scale]}]
    (println
     (Integer/toString (* scale (- a b)) base)))
  
  (def CONFIGURATION
      {:command     "toycalc"
       :description "A command-line toy calculator"
       :version     "0.0.1"
       :subcommands [{:command     "add"
                      :description "Adds two numbers together"
                      :runs        add_numbers}
                     ]})
    
  (defn -main
    "This is our entry point.
    Just pass parameters and configuration.
    Commands (functions) will be invoked as appropriate."
    [& args]
    (run-cmd args CONFIGURATION))