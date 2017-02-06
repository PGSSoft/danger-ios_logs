shared_examples_for 'files in changeset' do
  it 'should have three logs' do
    expect(log_method.length).to eq(3)
  end

  it 'has `print` log in first log element' do
    expect(log_method[0]).to eq('There remain `print` in the modified code.')
  end

  it 'has `print` log in second log element' do
    expect(log_method[1]).to eq('There remain `print` in the modified code.')
  end

  it 'has `NSLog` log in third log element' do
    expect(log_method[2]).to eq('There remain `NSLog` in the modified code.')
  end
end
