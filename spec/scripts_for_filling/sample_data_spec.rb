require 'palladium'
token = "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjI1MjQ1OTcyMDAsImlhdCI6MTU3NTkwMzYxMiwiaXNzIjoiQVBJIiwic2NvcGVzIjpbInJlc3VsdF9uZXciLCJyZXN1bHRfc2V0c19ieV9zdGF0dXMiXSwidXNlciI6eyJlbWFpbCI6IjFAZy5jb20ifX0.7kS_bHYJ9FFuBlJuAgDwBOWVmD88ulr5ytsqZeLppBU"

1.times do |i|
  describe "Run #{i}" do
    1000.times do |j|
      describe "Run #{2}" do
        it "#{i}:#{j}" do
          @palladium = Palladium.new(host: 'localhost',
                                     token: token,
                                     product: '5SampleData',
                                     plan: 'v8',
                                     run: "Run #{i}",
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
