require 'palladium'
token = "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjI1MjQ1OTcyMDAsImlhdCI6MTU3NTU1MTYxOCwiaXNzIjoiQVBJIiwic2NvcGVzIjpbInJlc3VsdF9uZXciLCJyZXN1bHRfc2V0c19ieV9zdGF0dXMiXSwidXNlciI6eyJlbWFpbCI6IjFAZy5jb20ifX0.arslTGacfLxdAxIR7l6fjKF0e6HvC0GCTLhw11IHVKk"

5.times do |i|
  describe "Run #{i}" do
    10.times do |j|
      describe "Run #{i}" do
        it "#{i}:#{j}" do
          @palladium = Palladium.new(host: 'localhost',
                                     token: token,
                                     product: 'SampleData',
                                     plan: 'v1',
                                     run: "Run #{i}",
                                     port: 9292)
          expect(true).to be_truthy
        end
      end
    end
    after :each do |example|
      @palladium.set_result(status: "Passed", description: "Ok", name: example.metadata[:description_args][0])
    end
  end
end
