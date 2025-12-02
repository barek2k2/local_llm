# spec/local_llm_spec.rb
require "spec_helper"
require "local_llm"

RSpec.describe LocalLlm do
  it "has a version number" do
    expect(LocalLlm::VERSION).not_to be_nil
  end

  it "has a configurable base_url" do
    LocalLlm.configure do |c|
      c.base_url = "http://example.com:1234"
    end

    expect(LocalLlm.config.base_url).to eq("http://example.com:1234")
  end

  it "has configurable default models" do
    LocalLlm.configure do |c|
      c.default_general_model = "llama2:13b"
      c.default_fast_model    = "mistral:7b-instruct"
      c.default_code_model    = "codellama:13b-instruct"
    end

    expect(LocalLlm.config.default_general_model).to eq("llama2:13b")
    expect(LocalLlm.config.default_fast_model).to eq("mistral:7b-instruct")
    expect(LocalLlm.config.default_code_model).to eq("codellama:13b-instruct")
  end

  it "exposes the main interface methods" do
    expect(LocalLlm).to respond_to(:ask)
    expect(LocalLlm).to respond_to(:chat)
    expect(LocalLlm).to respond_to(:models)
    expect(LocalLlm).to respond_to(:general)
    expect(LocalLlm).to respond_to(:fast)
    expect(LocalLlm).to respond_to(:code)
  end
end
