# frozen_string_literal: true

shared_examples_for 'files not in changeset' do
  it 'should have no message' do
    expect(messages).to be_empty
  end

  it 'should have no warnings' do
    expect(warnings).to be_empty
  end

  it 'should have no failures' do
    expect(failures).to be_empty
  end

  it 'should have no markdowns' do
    expect(markdowns).to be_empty
  end
end
