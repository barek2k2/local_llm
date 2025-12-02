# local_llm

**`local_llm`** is a lightweight Ruby gem that lets you talk to **locally installed LLMs via Ollama** — with **zero cloud dependency**, full **developer control**, and **configurable defaults**, including **real-time streaming support**.

It supports:
- Completely OFFLINE!
- Any Ollama model (LLaMA, Mistral, CodeLLaMA, Qwen, Phi, Gemma, etc.)
- Developer-configurable default models
- Developer-configurable Ollama API endpoint
- Developer-configurable **streaming or non-streaming**
- One-shot Q&A and multi-turn chat
- Works in plain Ruby & Rails
- 100% local & private

---

## 🚀 Features

- Use **any locally installed Ollama model**
- Change **default models at runtime**
- Enable or disable **real-time streaming**
- Works with:
  - `llama2`
  - `mistral`
  - `codellama`
  - `qwen`
  - `phi`
  - Anything supported by Ollama
- No API keys needed
- No cloud calls
- Full privacy
- Works completely offline

---

## 📦 Installation

### Install Ollama

Download from:

https://ollama.com

Then start it:

```bash
ollama serve
```

### How to Install New LLMs
```
ollama pull llama2:13b
ollama pull mistral:7b-instruct
ollama pull codellama:13b-instruct
ollama pull qwen2:7b
```

### Verify Installed Models
```
ollama list
```

### Configuration
```
LocalLlm.configure do |c|
  c.base_url = "http://localhost:11434"
  c.default_general_model = "llama2:13b"
  c.default_fast_model    = "mistral:7b-instruct"
  c.default_code_model    = "codellama:13b-instruct"
  c.default_stream = false   # true = stream by default, false = return full text
end
```

### Basic Usage (Non-Streaming)
```
LocalLlm.ask("llama2:13b", "What is HIPAA?")
LocalLlm.ask("qwen2:7b", "Explain transformers in simple terms.")

LocalLlm.general("What is a Denial of Service attack?")
LocalLlm.fast("Summarize this paragraph in 3 bullet points.")
LocalLlm.code("Write a Ruby method that returns factorial of n.")
```

### Constant Alias (LocalLlm vs LocalLLM)

For convenience and readability, `LocalLLM` is provided as a direct alias of `LocalLlm`.

This means **both constants work identically**:

```
LocalLlm.fast("Tell me About Bangladesh")
LocalLLM.fast("Explain HIPAA in simple terms.") # alias of LocalLlm
```

### Streaming Usage (Live Output)
```
LocalLlm.configure do |c|
  c.default_stream = true
end

LocalLlm.fast("Explain HIPAA in very simple words.") do |chunk|
  print chunk
end
```

### Per-Call Streaming Override
```
LocalLlm.fast("Explain LLMs in one paragraph.", stream: true) do |chunk|
  print chunk
end

full_text = LocalLlm.fast("Explain DoS attacks briefly.", stream: false)
puts full_text
```

### Full Chat API (Multi-Turn)
```
LocalLlm.chat("llama2:13b", [
  { "role" => "system", "content" => "You are a helpful assistant." },
  { "role" => "user",   "content" => "Explain LSTM." }
])
```

### List Installed Ollama Models from Ruby
```
LocalLlm.models
```

### Switching to Qwen (or Any New Model)
```
ollama pull qwen2:7b
```

```
LocalLlm.ask("qwen2:7b", "Explain HIPAA in simple terms.")
```

### Make Qwen the Default
```
LocalLlm.configure do |c|
  c.default_general_model = "qwen2:7b"
end

LocalLlm.general("Explain transformers.")
```

### 🔌 Remote Ollama / Docker Support
```
LocalLlm.configure do |c|
  c.base_url = "http://192.168.1.100:11434"
end
```

### Troubleshooting
##### Ollama Not Running
```
ollama serve
```

### Privacy & Security
 - 100% local inference
 - No cloud calls
 - No API keys
 - No data leaves your machine
 - Safe for HIPAA, SOC2, and regulated workflows where data privacy is a big concern