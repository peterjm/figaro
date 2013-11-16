require "spec_helper"

require "tempfile"

module Figaro
  describe Application do
    describe "#path" do
      it "is configurable via initialization" do
        application = Application.new(path: "/app/env.yml")

        expect(application.path).to eq("/app/env.yml")
      end

      it "is configurable via setter" do
        application = Application.new
        application.path = "/app/env.yml"

        expect(application.path).to eq("/app/env.yml")
      end

      it "casts to string" do
        application = Application.new(path: Pathname.new("/app/env.yml"))

        expect(application.path).to eq("/app/env.yml")
        expect(application.environment).not_to be_a(Pathname)
      end
    end

    describe "#environment" do
      it "is configurable via initialization" do
        application = Application.new(environment: "test")

        expect(application.environment).to eq("test")
      end

      it "is configurable via setter" do
        application = Application.new
        application.environment = "test"

        expect(application.environment).to eq("test")
      end

      it "casts to string" do
        NotString = Struct.new(:str) do
          def to_s; str; end
        end
        application = Application.new(environment: NotString.new("test"))

        expect(application.environment).to eq("test")
        expect(application.environment).not_to be_an(NotString)
      end
    end

    describe "#configuration" do
      def yaml_to_path(yaml)
        Tempfile.open("figaro") do |file|
          file.write(yaml)
          file.path
        end
      end

      it "loads values from YAML" do
        application = Application.new(path: yaml_to_path(<<-YAML))
foo: bar
YAML

        expect(application.configuration).to eq("foo" => "bar")
      end

      it "merges environment-specific values" do
        application = Application.new(path: yaml_to_path(<<-YAML), environment: "test")
foo: bar
test:
  foo: baz
YAML

        expect(application.configuration).to eq("foo" => "baz")
      end

      it "drops unused environment-specific values" do
        application = Application.new(path: yaml_to_path(<<-YAML), environment: "test")
foo: bar
test:
  foo: baz
production:
  foo: bad
YAML

        expect(application.configuration).to eq("foo" => "baz")
      end

      it "is empty when no YAML file is present" do
        application = Application.new(path: "/path/to/nowhere")

        expect(application.configuration).to eq({})
      end

      it "is empty when the YAML file is blank" do
        application = Application.new(path: yaml_to_path(""))

        expect(application.configuration).to eq({})
      end

      it "is empty when the YAML file contains only comments" do
        application = Application.new(path: yaml_to_path(<<-YAML))
# Comment
YAML

        expect(application.configuration).to eq({})
      end

      it "processes ERB" do
        application = Application.new(path: yaml_to_path(<<-YAML))
foo: <%= "bar".upcase %>
YAML

        expect(application.configuration).to eq("foo" => "BAR")
      end
    end

    describe "#load" do
      let!(:application) { Application.new }

      before do
        ::ENV.delete("foo")
        ::ENV.delete("FIGARO_foo")

        application.stub(configuration: { "foo" => "bar" })
      end

      it "merges values into ENV" do
        expect {
          application.load
        }.to change {
          ::ENV["foo"]
        }.from(nil).to("bar")
      end

      it "skips keys that have already been set externally" do
        ::ENV["foo"] = "baz"

        expect {
          application.load
        }.not_to change {
          ::ENV["foo"]
        }
      end

      it "sets keys that have already been set internally" do
        application.load

        application2 = Application.new
        application2.stub(configuration: { "foo" => "baz" })

        expect {
          application2.load
        }.to change {
          ::ENV["foo"]
        }.from("bar").to("baz")
      end

      it "warns when a key isn't a string" do
        application.stub(configuration: { foo: "bar" })

        expect(application).to receive(:warn).once

        application.load
      end

      it "warns when a value isn't a string" do
        application.stub(configuration: { "foo" => ["bar"] })

        expect(application).to receive(:warn).once

        application.load
      end
    end
  end
end
