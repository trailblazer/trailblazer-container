require "test_helper"
require "dry/container"
require "trailblazer/operation"
require "trailblazer/macro/contract"
require "trailblazer/macro"

class DryContainerTest < Minitest::Spec
  let(:container) {
    container = Dry::Container.new
    container.namespace('song') do
      namespace('create') do
        register('model.class') { Song }  # note how dependencies are namespaced depending on their domain.
        register('contract.default.class') { Song::Form }
      end
    end
    container.register('db') { String }
  }

  Song = Struct.new(:id)

  class Song
    Form = Struct.new(:valid?)
  end



  it "what" do
    # res = container.resolve('repositories.checkout.orders')
    # puts res.inspect

    class Validate < Trailblazer::Operation
      step Contract::Build()

    end

    class Song
      class Create < Trailblazer::Operation
        step Model()              # no options set here!
        step Subprocess(Validate)
        step :save

        def save(ctx, model:, **)
          ctx[:save] = ctx["db"].new
        end
      end
    end # Song

    require "trailblazer/container/namespaced"

    ctx              = Trailblazer::Context({params: {id: 1}}, {})
    create_container = Trailblazer::Container::Namespaced.new(container, ctx, "song.create")


    # raise ctx["song.create.model.class"].inspect
    # puts create_container[:params].inspect
    # puts create_container["model.class"].inspect

    signal, (ctx, _) = Trailblazer::Activity::TaskWrap.invoke(Song::Create, [create_container, {}])

    ctx.to_hash.inspect.must_equal %{{:params=>{:id=>1}, :model=>#<struct DryContainerTest::Song id=nil>, :"result.model"=><Result:true {} >, :"contract.default"=>#<struct DryContainerTest::Song::Form :valid?=#<struct DryContainerTest::Song id=nil>>, :save=>""}}
  end
end
