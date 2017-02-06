shared_examples_for 'logs in dockerfile' do |log_files|
  it "should have #{log_files.count} logs" do
    expect(logs.length).to eq(log_files.count)
  end

  log_files.each_index do |index|
    log_file = log_files[index]
    it "should have log in #{log_file.file} at $#{log_file.line}" do
      expect(logs[index]).to eq(log_file)
    end
  end
end
