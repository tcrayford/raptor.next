require "rack"
require "spec_helper"
require "raptor"

describe Raptor::Route do
  let(:injector) { Raptor::Injector.new }

  it "errors if redirect target doesn't exist"

  it "can render text" do
    app = Raptor::App.new(Object) {}
    route = Raptor::BuildsRoutes.new(app).root(:text => "the text")
    req = request("GET", "/posts")
    response = route.respond_to_request(injector, req)
    response.body.join.strip.should == "the text"
  end

  class OnlyIDOfFive
    def match?(id)
      id == '5'
    end
  end

  it "injects route params into the presenter" do
    route = Raptor::Route.new(:show, '/posts/:id', [OnlyIDOfFive.new], stub, stub, stub)
    req = request("GET", "/posts/5")
    route.match?(injector, req).should be_true
  end

  it "routes to nested routes"
  it "stores templates in templates directory, not views"
  it "allows overriding of the presenter class"
  it "doesn't require .html.erb on template names"
  it "includes type definitions in routes so they can be casted before injection"
end

class MatchingRequirement
  def self.match?
    true
  end
end

