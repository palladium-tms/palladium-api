require 'palladium'
token = "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjI1MjQ1OTcyMDAsImlhdCI6MTU5NTgwNjc4OSwiaXNzIjoiQVBJIiwic2NvcGVzIjpbInJlc3VsdF9uZXciLCJyZXN1bHRfc2V0c19ieV9zdGF0dXMiXSwidXNlciI6eyJlbWFpbCI6IjFAZy5jb20ifX0.WWnih7_OHUyIWzDb8V-8pBiTFQw1YTvBSvQvRaVUbHk
"

10.times do |i|
  describe "Run 1" do
    5.times do |j|
      describe "Run 1" do
        it "#{i}:#{j}" do
          @palladium = Palladium.new(host: 'localhost',
                                     token: token,
                                     product: 'Plans SampleData',
                                     plan: "v8 #{i}",
                                     run: "Run 2",
                                     port: 9292)
          expect(true).to be_truthy
        end
      end
    end
    after :each do |example|
      @palladium.set_result(status: ["Passed", "Failed"].sample(1)[0], description: "Ok", name: example.metadata[:description_args][0])
    end
  end
end
