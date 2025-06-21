# Aider Integration

This guide shows how to use HomeLab LLM Server with Aider for AI-powered pair programming.

## Setup

1. Start the LLM server:
```bash
llm start
```

2. Verify it's running:
```bash
llm status
```

## Basic Usage

Use the local server endpoint with Aider:

```bash
aider --model http://localhost:8080/v1/chat/completions
```

## Configuration

### Optimal Settings

For coding tasks, adjust your `.env`:

```env
CONTEXT_SIZE=8192    # Larger context for code
N_GPU_LAYERS=50      # Full GPU acceleration
```

### Model Selection

For best coding performance:

```bash
# Switch to coding-optimized model
llm model switch Qwen2.5-Coder-32B-Instruct-Q4_K_M.gguf
```

## Advanced Usage

### Project-Specific Configuration

Create a `.aider.conf.yml` in your project:

```yaml
model: http://localhost:8080/v1/chat/completions
auto-commits: false
dark-mode: true
```

### Multiple Models

Run different models for different tasks:

```bash
# For complex refactoring
llm model switch qwen2.5-coder-32b
aider --model http://localhost:8080/v1/chat/completions

# For quick edits (smaller, faster model)
llm model switch deepseek-coder-7b
aider --model http://localhost:8080/v1/chat/completions
```

## Performance Tips

1. **Monitor GPU usage**: `llm monitor`
2. **Adjust context size** based on your GPU memory
3. **Use appropriate quantization** (Q4_K_M is a good balance)
4. **Consider partial GPU offloading** for larger models

## Troubleshooting

- If Aider times out, check server logs: `llm logs`
- For slow responses, reduce context size or switch to smaller model
- Ensure sufficient VRAM is available: `llm status`