(ns upipe.main
    (:require
        cli-matic
        [cli-matic.core :refer [run-cmd]]
        [upipe.cmd-recent :as recent]))

(def CONFIGURATION
    {:command "upipe"
        :version "0.0.1"
        :description "A tool for managing youtube videos"
        :opts []
        :subcommands
            [{:command "recent"
                :description "Show and update the most recent videos."
                :opts []
                :runs recent/run}]})

(defn main [args] (run-cmd args CONFIGURATION))