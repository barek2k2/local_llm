# lib/local_llm.rb
# frozen_string_literal: true

require_relative "local_llm/version"
require_relative "local_llm/client"

module LocalLlm
  # Configuration object
  class Config
    attr_accessor :base_url,
                  :default_general_model,
                  :default_fast_model,
                  :default_code_model,
                  :default_stream

    def initialize
      @base_url              = "http://localhost:11434" # default Ollama
      @default_general_model = "llama2:13b"
      @default_fast_model    = "mistral:7b-instruct"
      @default_code_model    = "codellama:13b-instruct"
      @default_stream        = false
    end
  end

  # Global config access
  def self.config
    @config ||= Config.new
  end

  # DSL-style configuration:
  #
  #   LocalLlm.configure do |c|
  #     c.base_url              = "http://my-ollama-host:11434"
  #     c.default_general_model = "phi3:3.8b"
  #     c.default_fast_model    = "mistral:7b-instruct"
  #     c.default_code_model    = "codellama:13b-instruct"
  #   end
  #
  def self.configure
    yield(config)
  end

  class << self
    # We build a fresh client each time so changes to config.base_url
    # are always respected.
    def client
      Client.new(base_url: config.base_url)
    end

    # -------- Core API (any model) --------

    # One-shot Q&A with explicit model name
    #
    #   LocalLlm.ask("mistral:7b-instruct", "What is HIPAA?")
    #
    def ask(model, prompt, options = {}, &block)
      # allow per-call stream override, otherwise use config.default_stream
      stream = options.key?(:stream) ? options.delete(:stream) : config.default_stream
      client.ask(model: model, prompt: prompt, stream: stream, options: options, &block)
    end


    # Chat API with full messages array (OpenAI-style)
    #
    #   LocalLlm.chat("llama2:13b", [
    #     { "role" => "system", "content" => "You are a helpful assistant." },
    #     { "role" => "user",   "content" => "Explain LSTM." }
    #   ])
    #
    def chat(model, messages, options = {}, &block)
      stream = options.key?(:stream) ? options.delete(:stream) : config.default_stream
      client.chat(model: model, messages: messages, stream: stream, options: options, &block)
    end


    # List models from Ollama (`ollama list`)
    def models
      client.models
    end

    # -------- Convenience helpers using defaults --------

    # Use whatever the developer set as default_general_model
    def general(prompt, options = {}, &block)
      ask(config.default_general_model, prompt, options, &block)
    end

    # Use developer’s default_fast_model
    def fast(prompt, options = {}, &block)
      ask(config.default_fast_model, prompt, options, &block)
    end

    # Use developer’s default_code_model
    def code(prompt, options = {}, &block)
      ask(config.default_code_model, prompt, options, &block)
    end
  end
end

# Optional nicer alias if someone prefers LocalLLM
LocalLLM = LocalLlm unless defined?(LocalLLM)
