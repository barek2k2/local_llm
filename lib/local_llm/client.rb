# lib/local_llm/client.rb
require "net/http"
require "json"

module LocalLlm
  class Error < StandardError; end

  class Client
    def initialize(base_url:)
      @base_url = base_url
    end

    # Simple one-shot Q&A:
    #
    #   client.ask(model: "mistral:7b-instruct", prompt: "What is HIPAA?")
    #
    # stream: true/false (defaults handled by LocalLlm, but you can pass here too)
    def ask(model:, prompt:, stream: false, options: {}, &block)
      messages = [
        { "role" => "user", "content" => prompt }
      ]

      chat(model: model, messages: messages, stream: stream, options: options, &block)
    end

    # Full chat:
    #
    #   client.chat(
    #     model: "llama2:13b",
    #     messages: [
    #       { "role" => "system", "content" => "You are a helpful assistant." },
    #       { "role" => "user",   "content" => "Explain LSTM." }
    #     ],
    #     stream: true
    #   ) { |chunk| print chunk }
    #
    # options can include any extra Ollama fields (e.g. temperature)
    def chat(model:, messages:, stream: false, options: {}, &block)
      uri = URI.join(@base_url, "/api/chat")

      body_hash = {
        "model"    => model,
        "messages" => messages,
        "stream"   => stream
      }.merge(options)

      body_json = JSON.dump(body_hash)

      if stream
        stream_chat(uri, body_json, &block)
      else
        response = Net::HTTP.post(
          uri,
          body_json,
          "Content-Type" => "application/json"
        )

        unless response.is_a?(Net::HTTPSuccess)
          raise Error, "Ollama API error: #{response.code} #{response.body}"
        end

        data = JSON.parse(response.body)
        data.dig("message", "content") || ""
      end
    end

    # List available models (similar to `ollama list`)
    def models
      uri = URI.join(@base_url, "/api/tags")
      response = Net::HTTP.get_response(uri)

      unless response.is_a?(Net::HTTPSuccess)
        raise Error, "Ollama API error: #{response.code} #{response.body}"
      end

      data = JSON.parse(response.body)
      data["models"] || []
    end

    private

    # Basic streaming support for Ollama /api/chat with "stream": true
    #
    # If a block is given, yields each text chunk.
    # Always returns the full concatenated response as a String.
    def stream_chat(uri, body_json, &block)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")

      req = Net::HTTP::Post.new(uri.request_uri, "Content-Type" => "application/json")
      req.body = body_json

      full_content = +""

      http.request(req) do |res|
        unless res.is_a?(Net::HTTPSuccess)
          raise Error, "Ollama API error: #{res.code} #{res.body}"
        end

        res.read_body do |chunk|
          chunk.each_line do |line|
            line = line.strip
            next if line.empty?

            begin
              data = JSON.parse(line)
            rescue JSON::ParserError
              next
            end

            delta = data.dig("message", "content") || ""
            next if delta.empty?

            full_content << delta
            yield delta if block_given?
          end
        end
      end

      full_content
    end
  end
end
