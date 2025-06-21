#!/usr/bin/env bash

# Bash completion for llm command

_llm_completions() {
    local cur prev commands
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Main commands
    commands="start stop restart status logs monitor chat query model config update help"

    # Sub-commands
    case "${prev}" in
        llm)
            COMPREPLY=($(compgen -W "${commands}" -- "${cur}"))
            ;;
        model)
            COMPREPLY=($(compgen -W "list download current switch" -- "${cur}"))
            ;;
        config)
            COMPREPLY=($(compgen -W "show edit" -- "${cur}"))
            ;;
        switch)
            # List available model files
            if [[ -d "${LLM_HOME}/models" ]]; then
                local models=$(ls -1 "${LLM_HOME}/models"/*.gguf 2>/dev/null | xargs -n1 basename)
                COMPREPLY=($(compgen -W "${models}" -- "${cur}"))
            fi
            ;;
        logs)
            COMPREPLY=($(compgen -W "-f --follow --tail" -- "${cur}"))
            ;;
        *)
            ;;
    esac

    return 0
}

complete -F _llm_completions llm