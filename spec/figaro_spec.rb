require "spec_helper"

describe Figaro do
  describe ".env" do
    it "falls through to Figaro::ENV" do
      expect(Figaro.env).to eq(Figaro::ENV)
    end
  end

  describe ".backend" do
    let(:backend) { double(:backend) }

    it "defaults to the Rails application backend" do
      expect(Figaro.backend).to eq(Figaro::Application)
    end

    it "is configurable" do
      expect {
        Figaro.backend = backend
      }.to change {
        Figaro.backend
      }.from(Figaro::Application).to(backend)
    end
  end

  describe ".application" do
    let(:backend) { double(:backend) }
    let(:application) { double(:application) }
    let(:custom_application) { double(:custom_application) }

    before do
      Figaro.stub(:backend) { backend }
    end

    it "defaults to a new backend application" do
      backend.stub(:new) { application }
      expect(Figaro.application).to eq(application)
    end

    it "is configurable" do
      backend.stub(:new) { application }
      expect {
        Figaro.application = custom_application
      }.to change {
        Figaro.application
      }.from(application).to(custom_application)
    end

    it "respects the path" do
      Figaro.path = "the/path"
      expect(backend).to receive(:new).once.with(hash_including(path: "the/path")) { application }
      Figaro.application
    end

    it "respects the environment" do
      Figaro.environment = "foo"
      expect(backend).to receive(:new).once.with(hash_including(environment: "foo")) { application }
      Figaro.application
    end
  end

  describe ".load" do
    let(:application) { double(:application) }

    before do
      Figaro.stub(:application) { application }
    end

    it "loads the application configuration" do
      expect(application).to receive(:load).once.with(no_args)

      Figaro.load
    end
  end
end
