function __fresco.clone_plugin -a plugin
    function __fresco.resolve_dependency -a plugin
        set -l fresco_job_pids

        if test -f (__fresco.plugin_path $plugin)/fishfile
            for name in (cat (__fresco.plugin_path $plugin)/fishfile)
                if not test -d (__fresco.plugin_path $name)
                    fish -c "__fresco.clone_plugin $name" &
                    set fresco_job_pids $fresco_job_pids (jobs -p -l)
                end
            end
        end

        __fresco.wait $fresco_job_pids
    end

    function __fresco.append_plugin_to_list -a plugin
        if not command grep "^$plugin\$" $fresco_plugin_list_path >/dev/null
            echo $plugin >>$fresco_plugin_list_path
        end
    end

    if not test -e (__fresco.plugin_path $plugin)
        __fresco.log 'Download ' (__fresco.plugin_path $plugin)
        set -l url (string join -- '//' https: (__fresco.plugin_url $plugin))
        git clone $url (__fresco.plugin_path $plugin) >/dev/null ^/dev/null
        set -l git_status $status
        if test $git_status != 0
            command rm -rf (__fresco.plugin_path $plugin)
            __fresco.log "ERROR: `$plugin` is invalid plugin name"
        else
            __fresco.resolve_dependency $plugin
            __fresco.append_plugin_to_list $plugin
            __fresco.log "Enable $plugin"
            if not contains -- $plugin $fresco_plugins
                set fresco_plugins $fresco_plugins $plugin
            end
        end
        return $git_status
    end
end
