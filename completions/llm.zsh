#compdef llm

# Zsh completion for llm command

_llm() {
    local -a commands
    commands=(
        'start:Start the LLM server'
        'stop:Stop the LLM server'
        'restart:Restart the LLM server'
        'status:Show server status'
        'logs:View server logs'
        'monitor:Real-time monitoring'
        'chat:Interactive chat mode'
        'query:Send a single query'
        'model:Model management commands'
        'config:Configuration commands'
        'update:Update the server'
        'help:Show help'
    )

    local -a model_commands
    model_commands=(
        'list:List available models'
        'download:Download a new model'
        'current:Show current model'
        'switch:Switch to a different model'
    )

    local -a config_commands
    config_commands=(
        'show:Show current configuration'
        'edit:Edit configuration'
    )

    case $CURRENT in
        2)
            _describe 'command' commands
            ;;
        3)
            case ${words[2]} in
                model)
                    _describe 'model command' model_commands
                    ;;
                config)
                    _describe 'config command' config_commands
                    ;;
                logs)
                    _arguments '-f[Follow log output]' '--follow[Follow log output]'
                    ;;
                switch)
                    # List available model files
                    if [[ -d "${LLM_HOME}/models" ]]; then
                        local -a models
                        models=(${LLM_HOME}/models/*.gguf(:t))
                        _describe 'model file' models
                    fi
                    ;;
            esac
            ;;
        4)
            case ${words[2]} in
                model)
                    if [[ ${words[3]} == "switch" ]]; then
                        # List model files for switch command
                        if [[ -d "${LLM_HOME}/models" ]]; then
                            local -a models
                            models=(${LLM_HOME}/models/*.gguf(:t))
                            _describe 'model file' models
                        fi
                    fi
                    ;;
            esac
            ;;
    esac
}

_llm "$@"